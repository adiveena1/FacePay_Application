import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_transaction.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final PaymentTransaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, hh:mm:ss a');
    final formattedDate = dateFormat.format(transaction.timestamp);
    final isSuccess = transaction.status == PaymentStatus.success;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: isSuccess
                            ? AppTheme.accent.withAlpha(25)
                            : AppTheme.danger.withAlpha(25),
                        child: Icon(
                          isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isSuccess ? AppTheme.accent : AppTheme.danger,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${AppConstants.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        transaction.merchant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.merchant.upiId,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Technical Details Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const Divider(height: 24),
                      _buildRow('Transaction ID', transaction.id),
                      _buildRow('Timestamp', formattedDate),
                      _buildRow('Payment Status', transaction.status.name.toUpperCase()),
                      _buildRow('Gateway Mode', transaction.paymentMethod),
                      if (transaction.failureReason != null)
                        _buildRow('Failure Reason', transaction.failureReason!, isError: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Biometric Liveness Audit Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.security, color: AppTheme.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Face Security Audit Log',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildRow(
                        'Verification Required',
                        transaction.verificationRequired ? 'YES (Amount > ₹500)' : 'NO (Amount <= ₹500)',
                      ),
                      if (transaction.verificationRequired && transaction.verificationResult != null) ...[
                        _buildRow('Challenge Status', transaction.verificationResult!.status.name),
                        _buildRow('Blink Challenge', transaction.verificationResult!.blinkPassed ? 'PASSED' : 'NOT RECORDED'),
                        _buildRow('Head Pose Challenge', transaction.verificationResult!.headTurnPassed ? 'PASSED' : 'NOT RECORDED'),
                        _buildRow('Attempts Used', '${transaction.verificationResult!.attemptsUsed} / ${AppConstants.maxVerificationAttempts}'),
                        _buildRow('Audit Message', transaction.verificationResult!.message),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.privacy_tip_outlined, color: AppTheme.primary, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Privacy guarantee: On-device frame evaluation. No face embeddings or photos are stored in transaction logs.',
                                style: TextStyle(fontSize: 11, color: AppTheme.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isError ? AppTheme.danger : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
