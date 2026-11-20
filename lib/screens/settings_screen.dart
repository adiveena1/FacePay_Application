import 'package:flutter/material.dart';
import '../services/transaction_storage_service.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onDataReset;

  const SettingsScreen({
    super.key,
    required this.onDataReset,
  });

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Transaction History?'),
        content: const Text('All your past transaction records will be permanently deleted from this device.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Clear'),
            onPressed: () async {
              await TransactionStorageService.clearHistory();
              onDataReset();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction history cleared.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showResetDemoDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Demo Data?'),
        content: const Text(
          'This will restore wallet balance to ₹25,000.00, reset streaks, and clear custom badges.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Reset Demo'),
            onPressed: () async {
              await TransactionStorageService.resetDemoData();
              onDataReset();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application demo data reset.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Security Threshold Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppTheme.primary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Security Threshold Rules',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text(
                    'Active Verification Policy:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Transactions <= ₹500.00: Normal fast prototype flow\n'
                    '• Transactions > ₹500.00: On-device face liveness verification (Blink + Turn challenge)\n'
                    '• Max attempts allowed: 3 retries',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Privacy & Biometrics Policy Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.privacy_tip_rounded, color: AppTheme.accent, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Biometric Privacy Notice',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text(
                    'Privacy-First Architecture:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. 100% On-Device Processing: Camera frames are processed strictly in device memory via Google ML Kit.\n'
                    '2. Zero Remote Biometrics: No facial photographs, video streams, or raw face data are uploaded or logged.\n'
                    '3. Prototype Clarification: FacePay performs passive & active liveness verification (not full 1:1 facial identity matching).\n'
                    '4. Test Simulation: All payments operate in sandbox/test simulation mode.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Data Management
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: Colors.orange),
                  title: const Text('Clear Transaction History'),
                  subtitle: const Text('Erase locally recorded payment receipts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showClearHistoryDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded, color: AppTheme.danger),
                  title: const Text('Reset All Demo Data'),
                  subtitle: const Text('Restore initial ₹25,000 balance and badges'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showResetDemoDataDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About App Info
          const Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v1.0.0',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 2),
                Text(
                  'College PBL-3 Project Prototype • Sharda University',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
