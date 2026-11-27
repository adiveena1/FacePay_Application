import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facepay/main.dart';
import 'package:facepay/core/constants/app_constants.dart';
import 'package:facepay/core/utils/currency_formatter.dart';
import 'package:facepay/services/payment_validation_service.dart';
import 'package:facepay/services/qr_scanner_service.dart';
import 'package:facepay/services/payment_service.dart';
import 'package:facepay/services/transaction_storage_service.dart';
import 'package:facepay/services/rewards_service.dart';
import 'package:facepay/models/merchant.dart';
import 'package:facepay/models/payment_transaction.dart';
import 'package:facepay/models/verification_result.dart';
import 'package:facepay/models/user_rewards.dart';

void main() {
  group('Payment Validation & Threshold Rules (PBL-3 Requirement)', () {
    test('Amount <= ₹500 should NOT require face verification', () {
      expect(PaymentValidationService.requiresFaceVerification(100.00), isFalse);
      expect(PaymentValidationService.requiresFaceVerification(250.50), isFalse);
      expect(PaymentValidationService.requiresFaceVerification(500.00), isFalse);
    });

    test('Amount > ₹500 MUST require face verification', () {
      expect(PaymentValidationService.requiresFaceVerification(500.01), isTrue);
      expect(PaymentValidationService.requiresFaceVerification(501.00), isTrue);
      expect(PaymentValidationService.requiresFaceVerification(1000.00), isTrue);
      expect(PaymentValidationService.requiresFaceVerification(5000.00), isTrue);
    });

    test('Amount parsing and input validation sanitization', () {
      final valid = PaymentValidationService.validateAmount('250.75');
      expect(valid.isValid, isTrue);
      expect(valid.parsedAmount, 250.75);

      final withSymbol = PaymentValidationService.validateAmount('₹600.00');
      expect(withSymbol.isValid, isTrue);
      expect(withSymbol.parsedAmount, 600.00);

      final zero = PaymentValidationService.validateAmount('0.00');
      expect(zero.isValid, isFalse);

      final negative = PaymentValidationService.validateAmount('-50.00');
      expect(negative.isValid, isFalse);

      final malformed = PaymentValidationService.validateAmount('abc');
      expect(malformed.isValid, isFalse);
    });
  });

  group('QR Code Scanner Parsing', () {
    test('Parses UPI URI format with merchant and amount', () {
      const upiUri = 'upi://pay?pa=store@icici&pn=Campus%20Store&am=650.00&cu=INR&tn=Stationery';
      final parsed = QRScannerService.parseQRCode(upiUri);

      expect(parsed, isNotNull);
      expect(parsed!.merchant.name, 'Campus Store');
      expect(parsed.merchant.upiId, 'store@icici');
      expect(parsed.amount, 650.00);
      expect(parsed.note, 'Stationery');
    });

    test('Parses comma-separated prototype QR', () {
      const qr = 'Campus Cafeteria,cafeteria@upi,150.00';
      final parsed = QRScannerService.parseQRCode(qr);

      expect(parsed, isNotNull);
      expect(parsed!.merchant.name, 'Campus Cafeteria');
      expect(parsed.amount, 150.00);
    });

    test('Sample test QR scenarios cover above and below threshold', () {
      final samples = QRScannerService.getSampleTestQRCodes();
      expect(samples.length, greaterThanOrEqualTo(3));

      final belowThreshold = samples.where((s) => (s.amount ?? 0) <= 500 && s.amount != null);
      final aboveThreshold = samples.where((s) => (s.amount ?? 0) > 500);

      expect(belowThreshold.isNotEmpty, isTrue);
      expect(aboveThreshold.isNotEmpty, isTrue);
    });
  });

  group('End-to-End Payment Processing Engine', () {
    const demoMerchant = Merchant(
      id: 'M-TEST-1',
      name: 'Test Cafeteria',
      upiId: 'test@upi',
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        AppConstants.prefKeyBalance: 5000.00,
      });
      await TransactionStorageService.updateBalance(5000.00);
    });

    test('Transaction <= ₹500 processes directly without face verification', () async {
      final result = await PaymentService.processPayment(
        merchant: demoMerchant,
        amount: 250.00,
        verificationResult: null,
      );

      expect(result.isSuccess, isTrue);
      expect(result.transaction.status, PaymentStatus.success);
      expect(result.transaction.amount, 250.00);

      // Verify wallet balance deducted
      final newBalance = await TransactionStorageService.getBalance();
      expect(newBalance, 4750.00);
    });

    test('Transaction > ₹500 BLOCKED if face verification is missing', () async {
      final result = await PaymentService.processPayment(
        merchant: demoMerchant,
        amount: 1500.00,
        verificationResult: null,
      );

      expect(result.isSuccess, isFalse);
      expect(result.transaction.status, PaymentStatus.verificationFailed);
      expect(result.message, contains('Security Verification Failed'));

      // Verify wallet balance NOT deducted
      final balance = await TransactionStorageService.getBalance();
      expect(balance, 5000.00);
    });

    test('Transaction > ₹500 SUCCEEDS when face verification is passed', () async {
      final passedVerification = VerificationResult(
        status: VerificationStatus.passed,
        message: 'Liveness challenge completed successfully',
        attemptsUsed: 1,
        blinkPassed: true,
        headTurnPassed: true,
        timestamp: DateTime.now(),
      );

      final result = await PaymentService.processPayment(
        merchant: demoMerchant,
        amount: 1500.00,
        verificationResult: passedVerification,
      );

      expect(result.isSuccess, isTrue);
      expect(result.transaction.status, PaymentStatus.success);
      expect(result.transaction.verificationRequired, isTrue);

      // Verify wallet balance deducted
      final newBalance = await TransactionStorageService.getBalance();
      expect(newBalance, 3500.00);

      // Verify rewards streak updated
      final rewards = await RewardsService.getRewards();
      expect(rewards.totalHighValueVerifiedPayments, greaterThanOrEqualTo(1));
    });

    test('Rejects payment when wallet balance is insufficient', () async {
      final result = await PaymentService.processPayment(
        merchant: demoMerchant,
        amount: 9999.00,
        verificationResult: VerificationResult(
          status: VerificationStatus.passed,
          message: 'Passed',
          timestamp: DateTime.now(),
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(result.transaction.status, PaymentStatus.failed);
      expect(result.message, contains('Insufficient balance'));
    });
  });

  group('Monetary Precision & Minor Units (Paise Conversion)', () {
    test('Integer minor unit conversion prevents IEEE-754 precision errors', () {
      expect(CurrencyFormatter.toMinorUnits(500.00), equals(50000));
      expect(CurrencyFormatter.toMinorUnits(500.01), equals(50001));
      expect(CurrencyFormatter.toMinorUnits(0.99), equals(99));
      expect(CurrencyFormatter.fromMinorUnits(50000), equals(500.00));
      expect(CurrencyFormatter.fromMinorUnits(50001), equals(500.01));
    });

    test('Threshold boundary evaluation using minor units', () {
      expect(PaymentValidationService.requiresFaceVerification(500.00), isFalse);
      expect(PaymentValidationService.requiresFaceVerification(500.01), isTrue);
      expect(PaymentValidationService.requiresFaceVerification(999.00), isTrue);
    });

    test('Indian currency formatting handles minor units and standard currency symbols', () {
      final formatted = CurrencyFormatter.format(1250.50);
      expect(formatted, contains('1,250.50'));
    });
  });

  group('Fintech Recipient & Currency Security Integrity', () {
    test('Validates recipient Virtual Payment Address (VPA) correctly', () {
      expect(PaymentValidationService.validateRecipientVpa('merchant@icici').isValid, isTrue);
      expect(PaymentValidationService.validateRecipientVpa('student.council@oksbi').isValid, isTrue);
      expect(PaymentValidationService.validateRecipientVpa('facepay_store@upi').isValid, isTrue);
      expect(PaymentValidationService.validateRecipientVpa('invalid-vpa-without-at').isValid, isFalse);
      expect(PaymentValidationService.validateRecipientVpa('').isValid, isFalse);
      expect(PaymentValidationService.validateRecipientVpa('user@').isValid, isFalse);
    });

    test('Validates currency conformity to INR', () {
      expect(PaymentValidationService.validateCurrency('INR'), isTrue);
      expect(PaymentValidationService.validateCurrency('inr'), isTrue);
      expect(PaymentValidationService.validateCurrency('USD'), isFalse);
      expect(PaymentValidationService.validateCurrency('EUR'), isFalse);
    });

    test('Generates deterministic idempotency keys', () {
      final key1 = PaymentValidationService.generateIdempotencyKey(
        userId: 'USER-1',
        merchantVpa: 'STORE-1@upi',
        amount: 500.0,
        nonce: 'nonce-123',
      );
      final key2 = PaymentValidationService.generateIdempotencyKey(
        userId: 'USER-1',
        merchantVpa: 'STORE-1@upi',
        amount: 500.0,
        nonce: 'nonce-123',
      );
      final key3 = PaymentValidationService.generateIdempotencyKey(
        userId: 'USER-1',
        merchantVpa: 'STORE-2@upi',
        amount: 500.0,
        nonce: 'nonce-123',
      );

      expect(key1, isNotEmpty);
      expect(key1, equals(key2));
      expect(key1, isNot(equals(key3)));
    });

    test('Blocks transaction when verification times out', () async {
      final timeoutResult = VerificationResult(
        status: VerificationStatus.timeout,
        message: 'Face verification challenge timed out (15s limit exceeded)',
        attemptsUsed: 1,
        timestamp: DateTime.now(),
      );

      final result = await PaymentService.processPayment(
        merchant: const Merchant(id: 'M-1', name: 'Timeout Test', upiId: 'timeout@upi'),
        amount: 800.00,
        verificationResult: timeoutResult,
      );

      expect(result.isSuccess, isFalse);
      expect(result.transaction.status, PaymentStatus.verificationFailed);
      expect(result.message, contains('Security Verification Failed'));
    });
  });

  group('Rewards & Badges Calculation Logic', () {
    test('Default badges contains first_payment, secure_shield, streak', () {
      final badges = UserRewards.defaultBadges();
      expect(badges.any((b) => b.id == 'first_payment'), isTrue);
      expect(badges.any((b) => b.id == 'secure_shield'), isTrue);
      expect(badges.any((b) => b.id == 'security_streak'), isTrue);
    });
  });

  testWidgets('App renders Home Dashboard without throwing exceptions', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FacePayApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(AppConstants.appName), findsWidgets);
    expect(find.text('Scan & Pay'), findsOneWidget);
  });
}
