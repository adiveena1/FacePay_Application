import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qr_scanner_service.dart';
import '../core/theme/app_theme.dart';
import 'payment_confirmation_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _handleScannedData(rawValue);
        break;
      }
    }
  }

  void _handleScannedData(String rawData) {
    if (_isScanned) return;
    _isScanned = true;

    final parsedData = QRScannerService.parseQRCode(rawData);

    if (parsedData != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationScreen(qrPaymentData: parsedData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR code format. Please scan a valid payment QR.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      _isScanned = false;
    }
  }

  void _showTestQRPicker() {
    final samples = QRScannerService.getSampleTestQRCodes();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.science_rounded, color: AppTheme.primary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Select Test Demo QR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Test complete flow with preset amounts above and below ₹500',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ...samples.map((sample) {
                  final amountText = sample.amount != null
                      ? '₹${sample.amount!.toStringAsFixed(2)}'
                      : 'Open Amount';
                  final isAboveThreshold = (sample.amount ?? 0) > 500;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isAboveThreshold
                            ? AppTheme.primary.withAlpha(25)
                            : AppTheme.accent.withAlpha(25),
                        child: Icon(
                          isAboveThreshold ? Icons.face_rounded : Icons.flash_on_rounded,
                          color: isAboveThreshold ? AppTheme.primary : AppTheme.accent,
                        ),
                      ),
                      title: Text(
                        sample.merchant.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(sample.note ?? sample.merchant.upiId),
                      trailing: Text(
                        amountText,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: isAboveThreshold ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _handleScannedData(sample.rawData);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Payment QR'),
        actions: [
          IconButton(
            tooltip: 'Flashlight',
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            tooltip: 'Flip Camera',
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Live Camera QR Viewfinder
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(
                        'Camera error: ${error.errorCode.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.science),
                        label: const Text('Use Test QR Scenarios'),
                        onPressed: _showTestQRPicker,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // QR Scanner Overlay Box
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Align QR Code within frame',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox.shrink(),
                ],
              ),
            ),
          ),

          // Bottom Quick Bar: Test QRs Button for PBL-3 Evaluation
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.developer_mode_rounded, color: AppTheme.primary),
              label: const Text(
                'Demo / Test QR Presets',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: _showTestQRPicker,
            ),
          ),
        ],
      ),
    );
  }
}
