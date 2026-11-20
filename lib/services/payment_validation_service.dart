import '../core/constants/app_constants.dart';

class PaymentValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double? parsedAmount;

  const PaymentValidationResult({
    required this.isValid,
    this.errorMessage,
    this.parsedAmount,
  });
}

class PaymentValidationService {
  /// Strict requirement from PBL-3 specification:
  /// Amount <= 500.00: Normal prototype flow (returns false)
  /// Amount > 500.00: Requires face verification (returns true)
  static bool requiresFaceVerification(double amount) {
    return amount > AppConstants.faceVerificationThreshold;
  }

  /// Monetary validation to prevent malformed, negative, or zero amounts
  static PaymentValidationResult validateAmount(String? rawAmount) {
    if (rawAmount == null || rawAmount.trim().isEmpty) {
      return const PaymentValidationResult(
        isValid: false,
        errorMessage: 'Amount cannot be empty.',
      );
    }

    final sanitized = rawAmount.replaceAll(AppConstants.currencySymbol, '').trim();
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
        errorMessage: 'Amount exceeds maximum prototype transaction limit (₹1,00,000).',
      );
    }

    // Round to 2 decimal places
    final rounded = double.parse(parsed.toStringAsFixed(2));

    return PaymentValidationResult(
      isValid: true,
      parsedAmount: rounded,
    );
  }
}
