import '../models/merchant.dart';
import 'payment_validation_service.dart';

class QRPaymentData {
  final Merchant merchant;
  final double? amount;
  final String? currency;
  final String? note;
  final String? transactionRef;
  final String rawData;

  const QRPaymentData({
    required this.merchant,
    this.amount,
    this.currency = 'INR',
    this.note,
    this.transactionRef,
    required this.rawData,
  });
}

class QRScannerService {
  /// Parses standard UPI QR string or prototype QR string
  /// Complies with Section 7 Screen 5 requirements:
  /// pa: payee address
  /// pn: payee name
  /// am: amount
  /// cu: currency
  /// tn: transaction note
  /// tr: transaction reference
  static QRPaymentData? parseQRCode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final trimmed = raw.trim();

    // 1. Standard UPI URI scheme
    if (trimmed.toLowerCase().startsWith('upi://pay')) {
      return _parseUpiUri(trimmed);
    }

    // 2. Simple comma-separated prototype string: "Campus Cafeteria,campus@upi,150.00,Lunch"
    if (trimmed.contains(',')) {
      final parts = trimmed.split(',');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final upiId = parts[1].trim();
        double? amount;
        if (parts.length >= 3) {
          final val = PaymentValidationService.validateAmount(parts[2].trim());
          if (val.isValid) amount = val.parsedAmount;
        }
        final note = parts.length >= 4 ? parts[3].trim() : null;

        return QRPaymentData(
          merchant: Merchant(
            id: 'MERCH-${DateTime.now().millisecondsSinceEpoch % 10000}',
            name: name.isNotEmpty ? name : 'Demo Merchant',
            upiId: upiId.isNotEmpty ? upiId : 'merchant@upi',
          ),
          amount: amount,
          note: note,
          rawData: trimmed,
        );
      }
    }

    // 3. Fallback: Parse merchant from raw text or store code
    return QRPaymentData(
      merchant: Merchant(
        id: 'MERCH-${DateTime.now().millisecondsSinceEpoch % 10000}',
        name: trimmed.length > 25 ? trimmed.substring(0, 25) : trimmed,
        upiId: 'verified.merchant@facepay',
      ),
      amount: null,
      rawData: trimmed,
    );
  }

  static QRPaymentData? _parseUpiUri(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      final params = uri.queryParameters;

      final payeeName = params['pn'] != null ? Uri.decodeComponent(params['pn']!) : 'UPI Merchant';
      final payeeAddress = params['pa'] ?? 'payee@upi';
      final note = params['tn'] != null ? Uri.decodeComponent(params['tn']!) : null;
      final currency = params['cu'] ?? 'INR';
      final transactionRef = params['tr'];

      double? amount;
      if (params['am'] != null) {
        final val = PaymentValidationService.validateAmount(params['am']!);
        if (val.isValid) {
          amount = val.parsedAmount;
        }
      }

      return QRPaymentData(
        merchant: Merchant(
          id: 'MERCH-${payeeAddress.hashCode.abs() % 10000}',
          name: payeeName,
          upiId: payeeAddress,
          category: 'Digital Merchant',
        ),
        amount: amount,
        currency: currency,
        note: note,
        transactionRef: transactionRef,
        rawData: uriString,
      );
    } catch (_) {
      return null;
    }
  }

  /// Preset demonstration scenarios for evaluators without physical paper QR codes
  static List<QRPaymentData> getSampleTestQRCodes() {
    return [
      const QRPaymentData(
        merchant: Merchant(
          id: 'MERCH-001',
          name: 'Campus Cafeteria',
          upiId: 'cafeteria@sharda.upi',
          category: 'Food & Dining',
        ),
        amount: 150.00,
        note: 'Afternoon Snacks & Coffee',
        rawData: 'upi://pay?pa=cafeteria@sharda.upi&pn=Campus%20Cafeteria&am=150.00&cu=INR&tn=Afternoon%20Snacks%20%26%20Coffee',
      ),
      const QRPaymentData(
        merchant: Merchant(
          id: 'MERCH-002',
          name: 'Tech World Electronics',
          upiId: 'techworld@okhdfcbank',
          category: 'Electronics Store',
        ),
        amount: 1200.00,
        note: 'Wireless Keyboard & Mouse',
        rawData: 'upi://pay?pa=techworld@okhdfcbank&pn=Tech%20World%20Electronics&am=1200.00&cu=INR&tn=Wireless%20Keyboard%20%26%20Mouse',
      ),
      const QRPaymentData(
        merchant: Merchant(
          id: 'MERCH-003',
          name: 'University Bookstore',
          upiId: 'books@icici',
          category: 'Education & Stationery',
        ),
        amount: 480.00,
        note: 'PBL-3 Engineering Reference Guides',
        rawData: 'upi://pay?pa=books@icici&pn=University%20Bookstore&am=480.00&cu=INR&tn=PBL-3%20Engineering%20Reference%20Guides',
      ),
      const QRPaymentData(
        merchant: Merchant(
          id: 'MERCH-004',
          name: 'Global Cloud Systems',
          upiId: 'billing@cloudsys.upi',
          category: 'Cloud Services',
        ),
        amount: 2500.00,
        note: 'Annual Developer Cloud Subscription',
        rawData: 'upi://pay?pa=billing@cloudsys.upi&pn=Global%20Cloud%20Systems&am=2500.00&cu=INR&tn=Annual%20Developer%20Cloud%20Subscription',
      ),
    ];
  }
}
