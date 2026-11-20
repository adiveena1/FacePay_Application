import 'merchant.dart';
import 'verification_result.dart';

enum PaymentStatus {
  success,
  failed,
  cancelled,
  verificationFailed,
  pending,
}

class PaymentTransaction {
  final String id;
  final Merchant merchant;
  final double amount;
  final DateTime timestamp;
  final PaymentStatus status;
  final bool verificationRequired;
  final VerificationResult? verificationResult;
  final String paymentMethod;
  final String? failureReason;

  const PaymentTransaction({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.verificationRequired,
    this.verificationResult,
    this.paymentMethod = 'FacePay Simulator (Test)',
    this.failureReason,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchant': merchant.toJson(),
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
    'verificationRequired': verificationRequired,
    'verificationResult': verificationResult?.toJson(),
    'paymentMethod': paymentMethod,
    'failureReason': failureReason,
  };

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) => PaymentTransaction(
    id: json['id'] as String,
    merchant: Merchant.fromJson(json['merchant'] as Map<String, dynamic>),
    amount: (json['amount'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
    status: PaymentStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => PaymentStatus.failed,
    ),
    verificationRequired: json['verificationRequired'] as bool? ?? false,
    verificationResult: json['verificationResult'] != null
        ? VerificationResult.fromJson(json['verificationResult'] as Map<String, dynamic>)
        : null,
    paymentMethod: json['paymentMethod'] as String? ?? 'FacePay Simulator (Test)',
    failureReason: json['failureReason'] as String?,
  );
}
