import 'package:flutter/material.dart';
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
  final QRPaymentData qrPaymentData;

  const PaymentConfirmationScreen({
    super.key,
    required this.qrPaymentData,
  });

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    if (widget.qrPaymentData.amount != null) {
      _amountController.text = widget.qrPaymentData.amount!.toStringAsFixed(2);
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
    });

    final amount = validation.parsedAmount!;
    final requiresVerification = PaymentValidationService.requiresFaceVerification(amount);

    VerificationResult? verificationResult;

    // Step: Face Verification Check (Threshold > 500)
    if (requiresVerification) {
      // Launch guided on-device face verification
      final dynamic result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FaceVerificationScreen(
            amount: amount,
            merchantName: widget.qrPaymentData.merchant.name,
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
        final failMsg = verificationResult.message;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentResultScreen(
              transaction: PaymentTransaction(
                id: 'FP-AUTH-FAIL',
                merchant: widget.qrPaymentData.merchant,
                amount: amount,
                timestamp: DateTime.now(),
                status: PaymentStatus.verificationFailed,
                verificationRequired: true,
                verificationResult: verificationResult,
                failureReason: failMsg,
              ),
              message: failMsg,
            ),
          ),
        );
        return;
      }
    }

    // Step: Process Payment
    setState(() {
      _isProcessing = true;
    });

    final processResult = await PaymentService.processPayment(
      merchant: widget.qrPaymentData.merchant,
      amount: amount,
      verificationResult: verificationResult,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          transaction: processResult.transaction,
          message: processResult.message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final merchant = widget.qrPaymentData.merchant;
    final currentAmount = _getCurrentAmount() ?? 0.0;
    final requiresFaceCheck = PaymentValidationService.requiresFaceVerification(currentAmount);

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
                        backgroundColor: AppTheme.primary.withAlpha(25),
                        child: const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        merchant.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        merchant.upiId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (widget.qrPaymentData.note != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.qrPaymentData.note!,
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

              // Security Rule Notification Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: requiresFaceCheck
                      ? AppTheme.primary.withAlpha(15)
                      : AppTheme.accent.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: requiresFaceCheck
                        ? AppTheme.primary.withAlpha(80)
                        : AppTheme.accent.withAlpha(80),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      requiresFaceCheck ? Icons.face_retouching_natural : Icons.lock_outline_rounded,
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
                                ? 'Face Liveness Verification Required'
                                : 'Standard Fast Checkout',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: requiresFaceCheck ? AppTheme.primary : AppTheme.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            requiresFaceCheck
                                ? 'Amount is above ₹500.00. You will be asked to perform a blink and head-pose check before authorization.'
                                : 'Amount is ₹500.00 or below. Standard checkout authorization applies.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              AppButton(
                label: requiresFaceCheck ? 'Verify Face & Pay' : 'Confirm Payment',
                icon: requiresFaceCheck ? Icons.face_rounded : Icons.lock_open_rounded,
                isLoading: _isProcessing,
                onPressed: _handleAuthorize,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Cancel',
                isOutlined: true,
                color: AppTheme.textSecondary,
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
