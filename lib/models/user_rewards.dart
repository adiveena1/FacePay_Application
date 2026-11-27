class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  BadgeItem copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return BadgeItem(
      id: id,
      title: title,
      description: description,
      iconName: iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconName': iconName,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory BadgeItem.fromJson(Map<String, dynamic> json) => BadgeItem(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    iconName: json['iconName'] as String,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt']) : null,
  );
}

class UserRewards {
  final int currentStreak;
  final int totalSuccessfulPayments;
  final int totalHighValueVerifiedPayments;
  final List<BadgeItem> badges;
  final DateTime? lastPaymentDate;

  int get totalFaceVerifiedTransactions => totalHighValueVerifiedPayments;
  int get totalTransactions => totalSuccessfulPayments;
  List<BadgeItem> get unlockedBadges => badges.where((b) => b.isUnlocked).toList();

  const UserRewards({
    this.currentStreak = 0,
    this.totalSuccessfulPayments = 0,
    this.totalHighValueVerifiedPayments = 0,
    this.badges = const [],
    this.lastPaymentDate,
  });

  static List<BadgeItem> defaultBadges() => [
    const BadgeItem(
      id: 'first_payment',
      title: 'First Payment',
      description: 'Completed your very first secure transaction on FacePay',
      iconName: 'bolt',
    ),
    const BadgeItem(
      id: 'secure_shield',
      title: 'Secure Shield',
      description: 'Successfully verified face liveness on a transaction > ₹500',
      iconName: 'security',
    ),
    const BadgeItem(
      id: 'five_payments',
      title: 'High Five',
      description: 'Completed 5 successful transactions',
      iconName: 'star',
    ),
    const BadgeItem(
      id: 'ten_payments',
      title: 'Payment Pro',
      description: 'Completed 10 successful transactions',
      iconName: 'workspace_premium',
    ),
    const BadgeItem(
      id: 'security_streak',
      title: 'Security Streak',
      description: 'Maintained a 3-consecutive transaction streak without failures',
      iconName: 'local_fire_department',
    ),
  ];

  UserRewards copyWith({
    int? currentStreak,
    int? totalSuccessfulPayments,
    int? totalHighValueVerifiedPayments,
    List<BadgeItem>? badges,
    DateTime? lastPaymentDate,
  }) {
    return UserRewards(
      currentStreak: currentStreak ?? this.currentStreak,
      totalSuccessfulPayments: totalSuccessfulPayments ?? this.totalSuccessfulPayments,
      totalHighValueVerifiedPayments: totalHighValueVerifiedPayments ?? this.totalHighValueVerifiedPayments,
      badges: badges ?? this.badges,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'totalSuccessfulPayments': totalSuccessfulPayments,
    'totalHighValueVerifiedPayments': totalHighValueVerifiedPayments,
    'badges': badges.map((b) => b.toJson()).toList(),
    'lastPaymentDate': lastPaymentDate?.toIso8601String(),
  };

  factory UserRewards.fromJson(Map<String, dynamic> json) => UserRewards(
    currentStreak: json['currentStreak'] as int? ?? 0,
    totalSuccessfulPayments: json['totalSuccessfulPayments'] as int? ?? 0,
    totalHighValueVerifiedPayments: json['totalHighValueVerifiedPayments'] as int? ?? 0,
    badges: (json['badges'] as List<dynamic>?)
            ?.map((e) => BadgeItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        defaultBadges(),
    lastPaymentDate: json['lastPaymentDate'] != null ? DateTime.tryParse(json['lastPaymentDate']) : null,
  );
}
