import 'merchant.dart';
import 'verification_result.dart';
import '../core/utils/currency_formatter.dart';

/// Comprehensive payment transaction state model.
/// Follows standard fintech state machine:
/// created -> awaitingVerification -> authorized -> processing -> success / failed / pendingReconciliation
enum PaymentStatus {
  created,
  awaitingVerification,
  authorized,
  processing,
  success,
  failed,
  cancelled,
  pendingReconciliation,
  verificationFailed;

  bool get isTerminal =>
      this == PaymentStatus.success ||
      this == PaymentStatus.failed ||
      this == PaymentStatus.cancelled;

  bool get isSuccessful => this == PaymentStatus.success;
}

class PaymentTransaction {
  final String id;
  final Merchant merchant;
  final double amount;
  final int amountPaise;
  final String currency;
  final DateTime timestamp;
  final PaymentStatus status;
  final bool verificationRequired;
  final VerificationResult? verificationResult;
  final String paymentMethod;
  final String? failureReason;
  final bool isDemo;
  final String? idempotencyKey;
  final String? providerReference;
  final String? transactionNote;

  PaymentTransaction({
    required this.id,
    required this.merchant,
    required this.amount,
    int? amountPaise,
    this.currency = 'INR',
    required this.timestamp,
    required this.status,
    required this.verificationRequired,
    this.verificationResult,
    this.paymentMethod = 'FacePay Simulator (Test)',
    this.failureReason,
    this.isDemo = true,
    this.idempotencyKey,
    this.providerReference,
    this.transactionNote,
  }) : amountPaise = amountPaise ?? ((amount * 100).round());

  String get formattedAmount => CurrencyFormatter.format(amount);

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchant': merchant.toJson(),
    'amount': amount,
    'amountPaise': amountPaise,
    'currency': currency,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
    'verificationRequired': verificationRequired,
    'verificationResult': verificationResult?.toJson(),
    'paymentMethod': paymentMethod,
    'failureReason': failureReason,
    'isDemo': isDemo,
    'idempotencyKey': idempotencyKey,
    'providerReference': providerReference,
    'transactionNote': transactionNote,
  };

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    final rawAmount = (json['amount'] as num).toDouble();
    return PaymentTransaction(
      id: json['id'] as String,
      merchant: Merchant.fromJson(json['merchant'] as Map<String, dynamic>),
      amount: rawAmount,
      amountPaise: json['amountPaise'] as int? ?? (rawAmount * 100).round(),
      currency: json['currency'] as String? ?? 'INR',
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
      isDemo: json['isDemo'] as bool? ?? true,
      idempotencyKey: json['idempotencyKey'] as String?,
      providerReference: json['providerReference'] as String?,
      transactionNote: json['transactionNote'] as String?,
    );
  }

  PaymentTransaction copyWith({
    String? id,
    Merchant? merchant,
    double? amount,
    int? amountPaise,
    String? currency,
    DateTime? timestamp,
    PaymentStatus? status,
    bool? verificationRequired,
    VerificationResult? verificationResult,
    String? paymentMethod,
    String? failureReason,
    bool? isDemo,
    String? idempotencyKey,
    String? providerReference,
    String? transactionNote,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      amountPaise: amountPaise ?? this.amountPaise,
      currency: currency ?? this.currency,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      verificationRequired: verificationRequired ?? this.verificationRequired,
      verificationResult: verificationResult ?? this.verificationResult,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      failureReason: failureReason ?? this.failureReason,
      isDemo: isDemo ?? this.isDemo,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      providerReference: providerReference ?? this.providerReference,
      transactionNote: transactionNote ?? this.transactionNote,
    );
  }
}
