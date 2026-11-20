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

  /// Core payment processor
  /// Rules:
  /// 1. Re-validates amount immediately before execution.
  /// 2. Checks wallet balance.
  /// 3. If amount > 500, verifies that liveness verification was passed.
  /// 4. Executes payment simulation.
  /// 5. Deducts balance, records transaction, and updates gamification rewards.
  static Future<PaymentProcessResult> processPayment({
    required Merchant merchant,
    required double amount,
    required VerificationResult? verificationResult,
    PaymentGatewayMode gatewayMode = PaymentGatewayMode.facepaySimulator,
  }) async {
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

    // 2. Strict Threshold Enforcement
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
      );
      await TransactionStorageService.saveTransaction(failedTx);
      await RewardsService.recordTransaction(failedTx);
      return PaymentProcessResult(
        isSuccess: false,
        transaction: failedTx,
        message: 'Insufficient balance. Available: ₹${currentBalance.toStringAsFixed(2)}',
      );
    }

    // 4. Simulate payment processing delay (realistic UX)
    await Future.delayed(const Duration(milliseconds: 1200));

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
        message: 'Normal prototype checkout (<= ₹500)',
        timestamp: DateTime.now(),
      ),
      paymentMethod: gatewayMode == PaymentGatewayMode.razorpayTestSandbox
          ? 'Razorpay Sandbox (Simulated Test Mode)'
          : 'FacePay Secure Simulator',
    );

    // Save history and update rewards
    await TransactionStorageService.saveTransaction(successTx);
    await RewardsService.recordTransaction(successTx);

    return PaymentProcessResult(
      isSuccess: true,
      transaction: successTx,
      message: 'Payment of ₹${sanitizedAmount.toStringAsFixed(2)} authorized successfully!',
    );
  }
}
