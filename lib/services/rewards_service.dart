import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_rewards.dart';
import '../models/payment_transaction.dart';

class RewardsService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get current user rewards state
  static Future<UserRewards> getRewards() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(AppConstants.prefKeyRewards);
    if (rawJson == null || rawJson.isEmpty) {
      final initial = UserRewards(
        badges: UserRewards.defaultBadges(),
      );
      await saveRewards(initial);
      return initial;
    }
    try {
      return UserRewards.fromJson(jsonDecode(rawJson));
    } catch (_) {
      return UserRewards(badges: UserRewards.defaultBadges());
    }
  }

  /// Save rewards
  static Future<void> saveRewards(UserRewards rewards) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.prefKeyRewards, jsonEncode(rewards.toJson()));
  }

  /// Update rewards after a transaction
  /// Rules:
  /// - Only successful transactions contribute to streaks and badges.
  /// - Failed or cancelled transactions reset the current streak.
  /// - Badges are unlocked once and timestamped.
  static Future<UserRewards> recordTransaction(PaymentTransaction transaction) async {
    final current = await getRewards();
    final now = DateTime.now();

    if (transaction.status != PaymentStatus.success) {
      // Failed or cancelled breaks the consecutive streak
      final updated = current.copyWith(
        currentStreak: 0,
      );
      await saveRewards(updated);
      return updated;
    }

    // Success transaction
    final newStreak = current.currentStreak + 1;
    final totalSuccessful = current.totalSuccessfulPayments + 1;
    final totalHighValue = transaction.verificationRequired
        ? current.totalHighValueVerifiedPayments + 1
        : current.totalHighValueVerifiedPayments;

    // Check Badge Criteria
    final updatedBadges = current.badges.map((badge) {
      if (badge.isUnlocked) return badge;

      bool shouldUnlock = false;
      switch (badge.id) {
        case 'first_payment':
          if (totalSuccessful >= 1) shouldUnlock = true;
          break;
        case 'secure_shield':
          if (totalHighValue >= 1) shouldUnlock = true;
          break;
        case 'five_payments':
          if (totalSuccessful >= 5) shouldUnlock = true;
          break;
        case 'ten_payments':
          if (totalSuccessful >= 10) shouldUnlock = true;
          break;
        case 'security_streak':
          if (newStreak >= 3) shouldUnlock = true;
          break;
      }

      if (shouldUnlock) {
        return badge.copyWith(
          isUnlocked: true,
          unlockedAt: now,
        );
      }
      return badge;
    }).toList();

    final updated = current.copyWith(
      currentStreak: newStreak,
      totalSuccessfulPayments: totalSuccessful,
      totalHighValueVerifiedPayments: totalHighValue,
      badges: updatedBadges,
      lastPaymentDate: now,
    );

    await saveRewards(updated);
    return updated;
  }
}
