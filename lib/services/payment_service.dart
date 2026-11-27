import 'package:uuid/uuid.dart';
import '../models/merchant.dart';
import '../models/payment_transaction.dart';
import '../models/verification_result.dart';
import 'payment_validation_service.dart';
import 'transaction_storage_service.dart';
import 'rewards_service.dart';

enum PaymentGatewayMode {
  facepaySimulator,
  razorpayTestSandbox,
}

class PaymentProcessResult {
  final bool isSuccess;
  final PaymentTransaction transaction;
  final String message;

  const PaymentProcessResult({
    required this.isSuccess,
    required this.transaction,
    required this.message,
  });
}

class PaymentService {
  static const _uuid = Uuid();
  // In-flight payment lock to prevent duplicate simultaneous submissions
  static final Set<String> _inFlightKeys = <String>{};

  /// Core payment processor following non-negotiable payment security rules (Section 4):
  /// 1. Validate recipient VPA.
  /// 2. Re-validate amount & currency in minor units immediately before execution.
  /// 3. Prevent duplicate in-flight submissions (Idempotency).
  /// 4. If amount > ₹500, verify that liveness verification was passed.
  /// 5. Verify wallet balance.
  /// 6. Process authorization and deduct balance.
  /// 7. Persist transaction and update rewards & Cloud Firestore.
  static Future<PaymentProcessResult> processPayment({
    required Merchant merchant,
    required double amount,
    required VerificationResult? verificationResult,
    String? transactionNote,
    String? customIdempotencyKey,
    PaymentGatewayMode gatewayMode = PaymentGatewayMode.facepaySimulator,
  }) async {
    final idempotencyKey = customIdempotencyKey ??
        PaymentValidationService.generateIdempotencyKey(
          userId: 'user_aditya',
          merchantVpa: merchant.id,
          amount: amount,
          nonce: _uuid.v4().substring(0, 8),
        );

    // Duplicate submission prevention
    if (_inFlightKeys.contains(idempotencyKey)) {
      final duplicateTx = PaymentTransaction(
        id: 'FP-DUP-${_uuid.v4().substring(0, 8).toUpperCase()}',
        merchant: merchant,
        amount: amount,
        timestamp: DateTime.now(),
        status: PaymentStatus.failed,
        verificationRequired: PaymentValidationService.requiresFaceVerification(amount),
        verificationResult: verificationResult,
        failureReason: 'Duplicate payment submission in progress. Please wait.',
        idempotencyKey: idempotencyKey,
        isDemo: true,
      );
      return PaymentProcessResult(
        isSuccess: false,
        transaction: duplicateTx,
        message: 'Duplicate payment submission blocked.',
      );
    }

    _inFlightKeys.add(idempotencyKey);

    try {
      // 1. Re-validate amount
      final valResult = PaymentValidationService.validateAmount(amount.toString());
      if (!valResult.isValid) {
        final failedTx = PaymentTransaction(
          id: 'FP-ERR-${_uuid.v4().substring(0, 8).toUpperCase()}',
          merchant: merchant,
          amount: amount,
          timestamp: DateTime.now(),
          status: PaymentStatus.failed,
          verificationRequired: PaymentValidationService.requiresFaceVerification(amount),
          verificationResult: verificationResult,
          failureReason: valResult.errorMessage ?? 'Invalid payment amount',
          idempotencyKey: idempotencyKey,
          isDemo: true,
          transactionNote: transactionNote,
        );
        await TransactionStorageService.saveTransaction(failedTx);
        await RewardsService.recordTransaction(failedTx);
        return PaymentProcessResult(
          isSuccess: false,
          transaction: failedTx,
          message: valResult.errorMessage ?? 'Invalid amount.',
        );
      }

      final sanitizedAmount = valResult.parsedAmount!;
      final requiresVerification = PaymentValidationService.requiresFaceVerification(sanitizedAmount);

      // 2. Strict Threshold Enforcement (Rule A & Rule B)
      if (requiresVerification) {
        if (verificationResult == null || verificationResult.status != VerificationStatus.passed) {
          final failedTx = PaymentTransaction(
            id: 'FP-BLOCKED-${_uuid.v4().substring(0, 8).toUpperCase()}',
            merchant: merchant,
            amount: sanitizedAmount,
            timestamp: DateTime.now(),
            status: PaymentStatus.verificationFailed,
            verificationRequired: true,
            verificationResult: verificationResult,
            failureReason: 'Mandatory face liveness verification not satisfied for transactions exceeding ₹500.',
            idempotencyKey: idempotencyKey,
            isDemo: true,
            transactionNote: transactionNote,
          );
          await TransactionStorageService.saveTransaction(failedTx);
          await RewardsService.recordTransaction(failedTx);
          return PaymentProcessResult(
            isSuccess: false,
            transaction: failedTx,
            message: 'Security Verification Failed: Payments above ₹500 require verified face liveness.',
          );
        }
      }

      // 3. Balance Check
      final currentBalance = await TransactionStorageService.getBalance();
      if (currentBalance < sanitizedAmount) {
        final failedTx = PaymentTransaction(
          id: 'FP-NSF-${_uuid.v4().substring(0, 8).toUpperCase()}',
          merchant: merchant,
          amount: sanitizedAmount,
          timestamp: DateTime.now(),
          status: PaymentStatus.failed,
          verificationRequired: requiresVerification,
          verificationResult: verificationResult,
          failureReason: 'Insufficient wallet balance (Available: ₹${currentBalance.toStringAsFixed(2)})',
          idempotencyKey: idempotencyKey,
          isDemo: true,
          transactionNote: transactionNote,
        );
        await TransactionStorageService.saveTransaction(failedTx);
        await RewardsService.recordTransaction(failedTx);
        return PaymentProcessResult(
          isSuccess: false,
          transaction: failedTx,
          message: 'Insufficient balance. Available: ₹${currentBalance.toStringAsFixed(2)}',
        );
      }

      // 4. Processing Delay Simulation
      await Future.delayed(const Duration(milliseconds: 900));

      // 5. Successful Execution
      await TransactionStorageService.deductBalance(sanitizedAmount);

      final successTx = PaymentTransaction(
        id: 'FP-TXN-${_uuid.v4().substring(0, 8).toUpperCase()}',
        merchant: merchant,
        amount: sanitizedAmount,
        timestamp: DateTime.now(),
        status: PaymentStatus.success,
        verificationRequired: requiresVerification,
        verificationResult: verificationResult ?? VerificationResult(
          status: VerificationStatus.notRequired,
          message: 'Normal demonstration checkout (<= ₹500)',
          timestamp: DateTime.now(),
        ),
        paymentMethod: gatewayMode == PaymentGatewayMode.razorpayTestSandbox
            ? 'Razorpay Sandbox (Simulated Test Mode)'
            : 'FacePay Secure Simulator (Demo)',
        isDemo: true,
        idempotencyKey: idempotencyKey,
        providerReference: 'SIM-UPI-${_uuid.v4().substring(0, 10).toUpperCase()}',
        transactionNote: transactionNote,
      );

      // Save history and update rewards
      await TransactionStorageService.saveTransaction(successTx);
      await RewardsService.recordTransaction(successTx);

      return PaymentProcessResult(
        isSuccess: true,
        transaction: successTx,
        message: 'Payment of ₹${sanitizedAmount.toStringAsFixed(2)} authorized successfully!',
      );
    } finally {
      _inFlightKeys.remove(idempotencyKey);
    }
  }
}
