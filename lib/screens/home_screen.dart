import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/merchant.dart';
import '../models/payment_transaction.dart';
import '../models/user_rewards.dart';
import '../services/payment_validation_service.dart';
import '../services/transaction_storage_service.dart';
import '../services/rewards_service.dart';
import '../widgets/transaction_card.dart';
import '../widgets/reward_badge.dart';
import 'qr_scanner_screen.dart';
import 'payment_confirmation_screen.dart';
import 'transaction_history_screen.dart';
import 'transaction_details_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'onboarding_screen.dart';

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

  void _openSendMoneyDialog() {
    final vpaController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String? vpaError;
    String? amountError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Send Money (UPI Transfer)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkHeader,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: vpaController,
                    decoration: InputDecoration(
                      labelText: 'Recipient UPI ID (VPA)',
                      hintText: 'e.g., student@upi or store@okhdfcbank',
                      prefixIcon: const Icon(Icons.alternate_email),
                      errorText: vpaError,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      hintText: 'Enter amount (e.g., 250 or 1200)',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      errorText: amountError,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Note (Optional)',
                      hintText: 'e.g., Project materials or dinner',
                      prefixIcon: const Icon(Icons.notes),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final vpaVal = PaymentValidationService.validateRecipientVpa(vpaController.text);
                      final amtVal = PaymentValidationService.validateAmount(amountController.text);

                      if (!vpaVal.isValid || !amtVal.isValid) {
                        setModalState(() {
                          vpaError = vpaVal.errorMessage;
                          amountError = amtVal.errorMessage;
                        });
                        return;
                      }

                      Navigator.of(ctx).pop();

                      final recipientMerchant = Merchant(
                        id: 'VPA-${vpaVal.sanitizedVpa.hashCode.abs() % 10000}',
                        name: vpaVal.sanitizedVpa!,
                        upiId: vpaVal.sanitizedVpa!,
                        category: 'Direct Transfer',
                      );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PaymentConfirmationScreen(
                            merchant: recipientMerchant,
                            initialAmount: amtVal.parsedAmount,
                            note: noteController.text.trim().isNotEmpty
                                ? noteController.text.trim()
                                : null,
                          ),
                        ),
                      ).then((_) => _loadDashboardData());
                    },
                    child: const Text('Proceed to Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
            tooltip: 'How FacePay Works',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(isFromSettings: true),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'User Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
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
                            color: AppTheme.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
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
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'FacePay Digital Balance',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'DEMO WALLET',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.contactless_rounded, color: Colors.white70, size: 24),
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
                              flex: 3,
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
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.send_rounded, size: 18),
                                label: const Text('Send', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: _openSendMoneyDialog,
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                        Container(width: 1, height: 32, color: Colors.grey.shade200),
                        _buildStatItem(
                          icon: Icons.security_rounded,
                          iconColor: AppTheme.primary,
                          value: '${_rewards.totalFaceVerifiedTransactions}',
                          label: 'Face Verified',
                        ),
                        Container(width: 1, height: 32, color: Colors.grey.shade200),
                        _buildStatItem(
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: AppTheme.accent,
                          value: '${_rewards.totalTransactions}',
                          label: 'Total Paid',
                        ),
                      ],
                    ),
                  ),

                  // Gamified Badges Horizontal Ribbon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                          '${_rewards.unlockedBadges.length}/${_rewards.badges.length}',
                          style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 145,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _rewards.badges.length,
                      itemBuilder: (context, index) {
                        return RewardBadgeCard(badge: _rewards.badges[index]);
                      },
                    ),
                  ),

                  // Recent Transactions Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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
                        'No transactions yet. Scan a QR code or Send money to begin!',
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
