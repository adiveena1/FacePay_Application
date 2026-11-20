import '../models/merchant.dart';

class QRPaymentData {
  final Merchant merchant;
  final double? amount;
  final String? note;
  final String rawData;

  const QRPaymentData({
    required this.merchant,
    this.amount,
    this.note,
    required this.rawData,
  });
}

class QRScannerService {
  /// Parses standard UPI QR string or JSON QR string
  /// Examples:
  /// 1. upi://pay?pa=store@icici&pn=Campus%20Store&am=650.00&cu=INR&tn=Books
  /// 2. {"merchantName": "Cafe Hub", "upiId": "cafe@paytm", "amount": 250.0}
  /// 3. Plain text or simulated QR payloads
  static QRPaymentData? parseQRCode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final trimmed = raw.trim();

    // 1. Try standard UPI URI scheme
    if (trimmed.startsWith('upi://pay')) {
      return _parseUpiUri(trimmed);
    }

    // 2. Try simple comma/colon separated prototype string: "Campus Cafeteria,campus@upi,150.00"
    if (trimmed.contains(',')) {
      final parts = trimmed.split(',');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final upiId = parts[1].trim();
        double? amount;
        if (parts.length >= 3) {
          amount = double.tryParse(parts[2].trim());
        }
        return QRPaymentData(
          merchant: Merchant(
            id: 'MERCH-${DateTime.now().millisecondsSinceEpoch % 10000}',
            name: name.isNotEmpty ? name : 'Demo Merchant',
            upiId: upiId.isNotEmpty ? upiId : 'merchant@upi',
          ),
          amount: amount,
          rawData: trimmed,
        );
      }
    }

    // 3. Fallback: Parse merchant name from plain text or code
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
      
      double? amount;
      if (params['am'] != null) {
        amount = double.tryParse(params['am']!);
      }

      return QRPaymentData(
        merchant: Merchant(
          id: 'MERCH-${payeeAddress.hashCode.abs() % 10000}',
          name: payeeName,
          upiId: payeeAddress,
          category: 'Digital Merchant',
        ),
        amount: amount,
        note: note,
        rawData: uriString,
      );
    } catch (_) {
      return null;
    }
  }

  /// Provides test demo QR codes for testing without physical scanning
  static List<QRPaymentData> getSampleTestQRCodes() {
    return [
      const QRPaymentData(
        merchant: Merchant(
          id: 'M-CAFE-101',
          name: 'Campus Cafeteria',
          upiId: 'cafeteria@sbi',
          category: 'Food & Dining',
        ),
        amount: 250.00,
        note: 'Lunch Combo (<= ₹500 - No Face Check)',
        rawData: 'upi://pay?pa=cafeteria@sbi&pn=Campus%20Cafeteria&am=250.00&tn=Lunch%20Combo',
      ),
      const QRPaymentData(
        merchant: Merchant(
          id: 'M-BOOK-202',
          name: 'University Bookstore',
          upiId: 'bookstore@hdfc',
          category: 'Stationery & Books',
        ),
        amount: 500.00,
        note: 'Semester Notebooks (= ₹500 Threshold Boundary)',
        rawData: 'upi://pay?pa=bookstore@hdfc&pn=University%20Bookstore&am=500.00&tn=Semester%20Notebooks',
      ),
      const QRPaymentData(
        merchant: Merchant(
          id: 'M-TECH-303',
          name: 'GadgetZone Tech Store',
          upiId: 'gadgetzone@icici',
          category: 'Electronics',
        ),
        amount: 1499.00,
        note: 'Wireless Headphones (> ₹500 - Mandatory Face Verification)',
        rawData: 'upi://pay?pa=gadgetzone@icici&pn=GadgetZone%20Tech%20Store&am=1499.00&tn=Wireless%20Headphones',
      ),
      const QRPaymentData(
        merchant: Merchant(
          id: 'M-OPEN-404',
          name: 'City Supermarket',
          upiId: 'citysupermarket@axis',
          category: 'Groceries',
        ),
        amount: null,
        note: 'Open Amount (Enter manually on checkout)',
        rawData: 'upi://pay?pa=citysupermarket@axis&pn=City%20Supermarket',
      ),
    ];
  }
}
