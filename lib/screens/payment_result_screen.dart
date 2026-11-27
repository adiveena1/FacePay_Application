import 'package:flutter/material.dart';
import '../models/payment_transaction.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';

class PaymentResultScreen extends StatelessWidget {
  final PaymentTransaction transaction;
  final String? message;

  const PaymentResultScreen({
    super.key,
    required this.transaction,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = transaction.status == PaymentStatus.success;
    final displayMessage = message ??
        (isSuccess
            ? 'Your payment was authorized successfully!'
            : (transaction.failureReason ?? 'Transaction could not be authorized.'));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Transaction Status'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Status Icon
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: isSuccess
                                ? AppTheme.accent.withValues(alpha: 0.15)
                                : AppTheme.danger.withValues(alpha: 0.15),
                            child: Icon(
                              isSuccess
                                  ? Icons.check_circle_rounded
                                  : Icons.highlight_off_rounded,
                              size: 72,
                              color: isSuccess ? AppTheme.accent : AppTheme.danger,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            isSuccess ? 'Payment Authorized!' : 'Payment Not Completed',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSuccess ? AppTheme.accent : AppTheme.danger,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Message
                          Text(
                            displayMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mandatory Fintech Distinction Banner (Section 3, 9, 17)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 18, color: Colors.amber.shade800),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'DEMONSTRATION TRANSACTION — Simulated locally in prototype environment. Not an actual bank transfer.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Amount Card
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              child: Column(
                                children: [
                                  const Text(
                                    'Amount',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${AppConstants.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('To Merchant', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                      Text(
                                        transaction.merchant.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Transaction ID', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                      Text(
                                        transaction.id,
                                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Security Check', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                      Text(
                                        transaction.verificationRequired
                                            ? (transaction.verificationResult?.isSuccessful == true ? 'Face Verified (Pass)' : 'Verification Blocked')
                                            : 'Standard Flow (<= ₹500)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: transaction.verificationRequired
                                              ? AppTheme.accent
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (transaction.providerReference != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Reference', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                        Text(
                                          transaction.providerReference!,
                                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Return Home Button
                AppButton(
                  label: 'Back to Home',
                  icon: Icons.home_rounded,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
