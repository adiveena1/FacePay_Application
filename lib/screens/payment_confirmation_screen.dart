import 'package:flutter/material.dart';
import '../models/merchant.dart';
import '../models/payment_transaction.dart';
import '../models/verification_result.dart';
import '../services/qr_scanner_service.dart';
import '../services/payment_validation_service.dart';
import '../services/payment_service.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'face_verification_screen.dart';
import 'payment_result_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final QRPaymentData? qrPaymentData;
  final Merchant? merchant;
  final double? initialAmount;
  final String? note;

  const PaymentConfirmationScreen({
    super.key,
    this.qrPaymentData,
    this.merchant,
    this.initialAmount,
    this.note,
  }) : assert(qrPaymentData != null || merchant != null);

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  String? _amountError;

  Merchant get _activeMerchant =>
      widget.merchant ?? widget.qrPaymentData!.merchant;

  String? get _activeNote =>
      widget.note ?? widget.qrPaymentData?.note;

  @override
  void initState() {
    super.initState();
    final initAmt = widget.initialAmount ?? widget.qrPaymentData?.amount;
    if (initAmt != null) {
      _amountController.text = initAmt.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _getCurrentAmount() {
    final text = _amountController.text.trim();
    return double.tryParse(text);
  }

  Future<void> _handleAuthorize() async {
    if (_isProcessing) return;

    final text = _amountController.text.trim();
    final validation = PaymentValidationService.validateAmount(text);

    if (!validation.isValid) {
      setState(() {
        _amountError = validation.errorMessage;
      });
      return;
    }

    setState(() {
      _amountError = null;
      _isProcessing = true;
    });

    final amount = validation.parsedAmount!;
    final requiresVerification = PaymentValidationService.requiresFaceVerification(amount);

    VerificationResult? verificationResult;

    // Step: Face Verification Check (Threshold > ₹500)
    if (requiresVerification) {
      // Launch guided on-device face verification
      final dynamic result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FaceVerificationScreen(
            amount: amount,
            merchantName: _activeMerchant.name,
          ),
        ),
      );

      if (result is VerificationResult) {
        verificationResult = result;
      } else {
        // User backed out without completing
        verificationResult = VerificationResult(
          status: VerificationStatus.cancelledByUser,
          message: 'Verification dismissed by user',
          timestamp: DateTime.now(),
        );
      }

      // If liveness verification did not pass, abort transaction
      if (verificationResult.status != VerificationStatus.passed) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentResultScreen(
              transaction: PaymentTransaction(
                id: 'FP-AUTH-FAIL',
                merchant: _activeMerchant,
                amount: amount,
                timestamp: DateTime.now(),
                status: PaymentStatus.verificationFailed,
                verificationRequired: true,
                verificationResult: verificationResult,
                failureReason: verificationResult?.message ?? 'Facial liveness verification was not completed.',
                isDemo: true,
                transactionNote: _activeNote,
              ),
            ),
          ),
        );
        return;
      }
    }

    // Step: Payment Authorization & Processing
    try {
      final payResult = await PaymentService.processPayment(
        merchant: _activeMerchant,
        amount: amount,
        verificationResult: verificationResult,
        transactionNote: _activeNote,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentResultScreen(
            transaction: payResult.transaction,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAmount = _getCurrentAmount();
    final requiresFaceCheck = currentAmount != null &&
        PaymentValidationService.requiresFaceVerification(currentAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Merchant Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                        child: const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _activeMerchant.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activeMerchant.upiId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (_activeNote != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _activeNote!,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Amount Input Field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paying Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text(
                              AppConstants.currencySymbol,
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '0.00',
                          errorText: _amountError,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _amountError = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic Security Requirement Indicator (Rule A)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: requiresFaceCheck
                      ? AppTheme.primary.withValues(alpha: 0.08)
                      : AppTheme.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: requiresFaceCheck
                        ? AppTheme.primary.withValues(alpha: 0.3)
                        : AppTheme.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      requiresFaceCheck ? Icons.face_retouching_natural : Icons.flash_on_rounded,
                      color: requiresFaceCheck ? AppTheme.primary : AppTheme.accent,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requiresFaceCheck
                                ? 'Security Level: Facial Liveness Required'
                                : 'Security Level: Fast Micro-Checkout',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: requiresFaceCheck ? AppTheme.primary : AppTheme.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            requiresFaceCheck
                                ? 'Amount exceeds ₹500.00. High-value payment requires on-device eye-blink & head-turn verification.'
                                : 'Amount is ₹500.00 or less. Payment will be authorized immediately without camera prompt.',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pay / Confirm Button
              AppButton(
                label: currentAmount != null && requiresFaceCheck
                    ? 'Verify Face & Pay'
                    : 'Pay Now',
                icon: currentAmount != null && requiresFaceCheck
                    ? Icons.camera_alt_outlined
                    : Icons.lock_outline,
                isLoading: _isProcessing,
                onPressed: _handleAuthorize,
              ),
              const SizedBox(height: 12),

              // Cancel Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
