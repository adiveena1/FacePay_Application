import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Centralized currency and monetary precision utility.
/// Converts between major currency units (Rupees) and minor units (Paise)
/// to prevent floating-point rounding errors in fintech calculations.
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  /// Format an amount into standard Indian currency format (e.g. ₹1,200.00)
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format paise (minor units) to currency string
  static String formatPaise(int paise) {
    return _formatter.format(fromMinorUnits(paise));
  }

  /// Convert standard Rupee double to minor currency units (Paise, integer)
  /// e.g. 500.50 -> 50050
  static int toMinorUnits(double amount) {
    return (amount * 100).round();
  }

  /// Convert minor currency units (Paise, integer) to standard Rupee double
  /// e.g. 50050 -> 500.50
  static double fromMinorUnits(int paise) {
    return paise / 100.0;
  }
}
