import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_transaction.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class TransactionCard extends StatelessWidget {
  final PaymentTransaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');
    final formattedDate = dateFormat.format(transaction.timestamp);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (transaction.status) {
      case PaymentStatus.success:
        statusColor = AppTheme.accent;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Success';
        break;
      case PaymentStatus.failed:
        statusColor = AppTheme.danger;
        statusIcon = Icons.cancel_rounded;
        statusText = 'Failed';
        break;
      case PaymentStatus.verificationFailed:
        statusColor = Colors.deepOrange;
        statusIcon = Icons.gpp_bad_rounded;
        statusText = 'Face Check Failed';
        break;
      case PaymentStatus.cancelled:
        statusColor = AppTheme.textMuted;
        statusIcon = Icons.remove_circle_outline_rounded;
        statusText = 'Cancelled';
        break;
      case PaymentStatus.processing:
      case PaymentStatus.pendingReconciliation:
        statusColor = AppTheme.accentAmber;
        statusIcon = Icons.timelapse_rounded;
        statusText = 'Processing';
        break;
      default:
        statusColor = AppTheme.accentAmber;
        statusIcon = Icons.hourglass_empty_rounded;
        statusText = 'Pending';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar or category icon
              CircleAvatar(
                radius: 24,
                backgroundColor: statusColor.withAlpha(30),
                child: Icon(statusIcon, color: statusColor, size: 26),
              ),
              const SizedBox(width: 14),
              // Merchant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.merchant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Face Verification tag if required
                    if (transaction.verificationRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.face_retouching_natural, size: 12, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              'Face Liveness Verified',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AppConstants.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: transaction.status == PaymentStatus.success
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
