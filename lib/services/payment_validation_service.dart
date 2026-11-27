import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';

class PaymentValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double? parsedAmount;
  final int? amountPaise;

  const PaymentValidationResult({
    required this.isValid,
    this.errorMessage,
    this.parsedAmount,
    this.amountPaise,
  });
}

class RecipientValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? sanitizedVpa;

  const RecipientValidationResult({
    required this.isValid,
    this.errorMessage,
    this.sanitizedVpa,
  });
}

class PaymentValidationService {
  /// Non-negotiable payment threshold rule (Section 4 Rule A):
  /// Amount <= ₹500.00: Normal checkout flow (returns false)
  /// Amount > ₹500.00: Facial liveness verification required (returns true)
  static bool requiresFaceVerification(double amount) {
    // Exact minor currency unit comparison to prevent floating-point rounding errors
    final amountPaise = CurrencyFormatter.toMinorUnits(amount);
    final thresholdPaise = CurrencyFormatter.toMinorUnits(AppConstants.faceVerificationThreshold);
    return amountPaise > thresholdPaise;
  }

  /// Monetary validation to prevent malformed, negative, zero, or floating-point precision errors
  static PaymentValidationResult validateAmount(String? rawAmount) {
    if (rawAmount == null || rawAmount.trim().isEmpty) {
      return const PaymentValidationResult(
        isValid: false,
        errorMessage: 'Amount cannot be empty.',
      );
    }

    final sanitized = rawAmount
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll(',', '')
        .trim();
    final parsed = double.tryParse(sanitized);

    if (parsed == null) {
      return const PaymentValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid monetary amount.',
      );
    }

    if (parsed <= 0) {
      return const PaymentValidationResult(
        isValid: false,
        errorMessage: 'Payment amount must be greater than ₹0.00.',
      );
    }

    if (parsed > 100000.00) {
      return const PaymentValidationResult(
        isValid: false,
        errorMessage: 'Amount exceeds maximum payment limit of ₹1,00,000.00.',
      );
    }

    // Convert to minor units (Paise) to eliminate floating point imprecision
    final paise = CurrencyFormatter.toMinorUnits(parsed);
    final normalizedRupees = CurrencyFormatter.fromMinorUnits(paise);

    return PaymentValidationResult(
      isValid: true,
      parsedAmount: normalizedRupees,
      amountPaise: paise,
    );
  }

  /// Validate supported currency (Indian Rupee - INR)
  static bool validateCurrency(String? currency) {
    if (currency == null || currency.trim().isEmpty) return true; // defaults to INR
    final c = currency.trim().toUpperCase();
    return c == 'INR' || c == '₹';
  }

  /// Validate UPI Virtual Payment Address (VPA / UPI ID)
  static RecipientValidationResult validateRecipientVpa(String? rawVpa) {
    if (rawVpa == null || rawVpa.trim().isEmpty) {
      return const RecipientValidationResult(
        isValid: false,
        errorMessage: 'Recipient UPI ID or address cannot be empty.',
      );
    }

    final trimmed = rawVpa.trim();
    // Standard UPI ID pattern: username@bankhandle (e.g. merchant@upi, user@okhdfcbank)
    final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');

    if (!upiRegex.hasMatch(trimmed)) {
      return const RecipientValidationResult(
        isValid: false,
        errorMessage: 'Invalid UPI ID format. Expected format: username@bank (e.g., store@upi).',
      );
    }

    return RecipientValidationResult(
      isValid: true,
      sanitizedVpa: trimmed.toLowerCase(),
    );
  }

  /// Generate an idempotency key binding transaction metadata
  /// to prevent accidental or malicious duplicate payment submissions
  static String generateIdempotencyKey({
    required String userId,
    required String merchantVpa,
    required double amount,
    required String nonce,
  }) {
    final cleanMerchant = merchantVpa.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final amountInt = CurrencyFormatter.toMinorUnits(amount);
    return 'IDEM-$cleanMerchant-$amountInt-$nonce';
  }
}
