import 'package:flutter/material.dart';
import '../models/user_rewards.dart';
import '../core/theme/app_theme.dart';

class RewardBadgeWidget extends StatelessWidget {
  final BadgeItem badge;

  const RewardBadgeWidget({
    super.key,
    required this.badge,
  });

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt_rounded;
      case 'security':
        return Icons.shield_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;

    return Container(
      width: 135,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? AppTheme.accent.withAlpha(120) : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: AppTheme.accent.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isUnlocked
                ? AppTheme.accent.withAlpha(30)
                : Colors.grey.shade300,
            child: Icon(
              _resolveIcon(badge.iconName),
              color: isUnlocked ? AppTheme.accent : Colors.grey.shade600,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? AppTheme.textPrimary : Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            isUnlocked ? 'Unlocked' : 'Locked',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? AppTheme.accent : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
