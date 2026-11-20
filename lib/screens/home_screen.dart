import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/payment_transaction.dart';
import '../models/user_rewards.dart';
import '../services/transaction_storage_service.dart';
import '../services/rewards_service.dart';
import '../widgets/transaction_card.dart';
import '../widgets/reward_badge.dart';
import 'qr_scanner_screen.dart';
import 'transaction_history_screen.dart';
import 'transaction_details_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = AppConstants.defaultInitialBalance;
  List<PaymentTransaction> _recentTransactions = [];
  UserRewards _rewards = const UserRewards();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    final balance = await TransactionStorageService.getBalance();
    final allTxs = await TransactionStorageService.getTransactions();
    final rewards = await RewardsService.getRewards();

    if (!mounted) return;

    setState(() {
      _balance = balance;
      _recentTransactions = allTxs.take(3).toList();
      _rewards = rewards;
      _isLoading = false;
    });
  }

  void _navigateToScanQR() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.face_retouching_natural, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings & Privacy',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(onDataReset: _loadDashboardData),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 30),
                children: [
                  // Greeting & Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                            ),
                            Text(
                              AppConstants.defaultUserName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        // Security Badge Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accent.withAlpha(80)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: AppTheme.accent, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Face Shield Active',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Wallet Balance Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryDark, AppTheme.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(80),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FacePay Digital Balance',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            Icon(Icons.contactless_rounded, color: Colors.white70, size: 24),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${AppConstants.currencySymbol}${_balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                                label: const Text('Scan & Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: _navigateToScanQR,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Streak & Security Stats Ribbon
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: Colors.deepOrange,
                          value: '${_rewards.currentStreak}',
                          label: 'Streak',
                        ),
                        Container(width: 1, height: 36, color: Colors.grey.shade200),
                        _buildStatItem(
                          icon: Icons.shield_rounded,
                          iconColor: AppTheme.primary,
                          value: '${_rewards.totalHighValueVerifiedPayments}',
                          label: 'Face Verified',
                        ),
                        Container(width: 1, height: 36, color: Colors.grey.shade200),
                        _buildStatItem(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppTheme.accent,
                          value: '${_rewards.totalSuccessfulPayments}',
                          label: 'Total Paid',
                        ),
                      ],
                    ),
                  ),

                  // Gamification Badges Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Security Achievements',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${_rewards.badges.where((b) => b.isUnlocked).length}/${_rewards.badges.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 135,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _rewards.badges.length,
                      itemBuilder: (context, index) {
                        return RewardBadgeWidget(badge: _rewards.badges[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recent Transactions Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                            );
                            _loadDashboardData();
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),

                  // Recent Transactions List
                  if (_recentTransactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text(
                        'No transactions yet. Scan a QR code to begin!',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  else
                    ..._recentTransactions.map((tx) {
                      return TransactionCard(
                        transaction: tx,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailsScreen(transaction: tx),
                            ),
                          );
                          _loadDashboardData();
                        },
                      );
                    }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan QR', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _navigateToScanQR,
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
