enum VerificationType {
  none,
  livenessChallenge,
}

enum VerificationStatus {
  notRequired,
  pending,
  passed,
  failed,
  timeout,
  exhaustedAttempts,
  cancelledByUser,
}

class VerificationResult {
  final VerificationStatus status;
  final String message;
  final int attemptsUsed;
  final bool blinkPassed;
  final bool headTurnPassed;
  final DateTime timestamp;

  const VerificationResult({
    required this.status,
    required this.message,
    this.attemptsUsed = 1,
    this.blinkPassed = false,
    this.headTurnPassed = false,
    required this.timestamp,
  });

  bool get isSuccessful => status == VerificationStatus.passed || status == VerificationStatus.notRequired;

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'message': message,
    'attemptsUsed': attemptsUsed,
    'blinkPassed': blinkPassed,
    'headTurnPassed': headTurnPassed,
    'timestamp': timestamp.toIso8601String(),
  };

  factory VerificationResult.fromJson(Map<String, dynamic> json) => VerificationResult(
    status: VerificationStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => VerificationStatus.notRequired,
    ),
    message: json['message'] as String? ?? '',
    attemptsUsed: json['attemptsUsed'] as int? ?? 1,
    blinkPassed: json['blinkPassed'] as bool? ?? false,
    headTurnPassed: json['headTurnPassed'] as bool? ?? false,
    timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
  );
}
