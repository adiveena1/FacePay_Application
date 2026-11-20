import 'package:flutter/material.dart';
import '../models/payment_transaction.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';

class PaymentResultScreen extends StatelessWidget {
  final PaymentTransaction transaction;
  final String message;

  const PaymentResultScreen({
    super.key,
    required this.transaction,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = transaction.status == PaymentStatus.success;

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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Status Icon
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: isSuccess
                              ? AppTheme.accent.withAlpha(30)
                              : AppTheme.danger.withAlpha(30),
                          child: Icon(
                            isSuccess
                                ? Icons.check_circle_rounded
                                : Icons.highlight_off_rounded,
                            size: 72,
                            color: isSuccess ? AppTheme.accent : AppTheme.danger,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          isSuccess ? 'Payment Successful!' : 'Payment Not Authorized',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSuccess ? AppTheme.accent : AppTheme.danger,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Message
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Amount Card
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            child: Column(
                              children: [
                                const Text(
                                  'Amount Paid',
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
                                    const Text('To Merchant', style: TextStyle(color: AppTheme.textSecondary)),
                                    Text(
                                      transaction.merchant.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Transaction ID', style: TextStyle(color: AppTheme.textSecondary)),
                                    Text(
                                      transaction.id,
                                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Face Verification', style: TextStyle(color: AppTheme.textSecondary)),
                                    Text(
                                      transaction.verificationRequired
                                          ? (transaction.verificationResult?.isSuccessful == true ? 'Verified Pass' : 'Failed')
                                          : 'Not Required (<= ₹500)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: transaction.verificationRequired
                                            ? AppTheme.accent
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
