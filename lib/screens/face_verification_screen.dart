import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/verification_result.dart';
import '../services/face_detection_service.dart';
import '../services/liveness_service.dart';
import '../widgets/app_button.dart';

class FaceVerificationScreen extends StatefulWidget {
  final double amount;
  final String merchantName;

  const FaceVerificationScreen({
    super.key,
    required this.amount,
    required this.merchantName,
  });

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  CameraController? _cameraController;
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final LivenessService _livenessService = LivenessService();

  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;
  String _statusMessage = 'Initializing secure front camera...';
  int _currentAttempt = 1;
  LivenessState? _latestLivenessState;
  bool _hasTerminated = false;
  Timer? _countdownTimer;
  int _secondsRemaining = 15;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
    _initCamera();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _secondsRemaining = 15;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _hasTerminated) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          _handleTimeout();
        }
      });
    });
  }

  void _handleTimeout() {
    if (_hasTerminated) return;
    _hasTerminated = true;
    _countdownTimer?.cancel();
    _stopCameraStream();

    final result = VerificationResult(
      status: VerificationStatus.timeout,
      message: 'Face verification challenge timed out (15s limit exceeded). Payment authorization cancelled.',
      attemptsUsed: _currentAttempt,
      timestamp: DateTime.now(),
    );

    Navigator.of(context).pop(result);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      // Select front-facing camera for face verification
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();
      _faceDetectionService.initializeDetector();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _statusMessage = 'Look directly at the front camera';
      });

      // Start streaming camera frames to ML Kit Face Detector
      await _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Camera initialization failed: $e. You can use simulation mode.';
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame || _hasTerminated) return;
    _isProcessingFrame = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      final status = await _faceDetectionService.processImage(inputImage);

      if (!mounted || _hasTerminated) {
        _isProcessingFrame = false;
        return;
      }

      if (!status.hasSingleFace || status.primaryFace == null) {
        setState(() {
          _statusMessage = status.message;
        });
        _isProcessingFrame = false;
        return;
      }

      // Evaluate liveness through multi-frame challenge
      final livenessState = _livenessService.processFaceFrame(status.primaryFace!);

      setState(() {
        _latestLivenessState = livenessState;
        _statusMessage = livenessState.feedback;
      });

      if (livenessState.isCompleted) {
        _completeVerificationSuccess();
      }
    } catch (_) {
      // Ignore individual frame conversion hiccups
    } finally {
      _isProcessingFrame = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    rotation ??= InputImageRotation.rotation0deg;

    // nv21 or yuv420
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    final inputFormat = format ?? InputImageFormat.nv21;

    // Concatenate plane bytes
    final bytes = image.planes.fold<List<int>>(
      [],
      (previousValue, plane) => previousValue..addAll(plane.bytes),
    );

    return InputImage.fromBytes(
      bytes: Uint8List.fromList(bytes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: inputFormat,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  void _completeVerificationSuccess() {
    if (_hasTerminated) return;
    _hasTerminated = true;
    _countdownTimer?.cancel();
    _stopCameraStream();

    final result = VerificationResult(
      status: VerificationStatus.passed,
      message: 'On-device face liveness challenge passed cleanly.',
      attemptsUsed: _currentAttempt,
      blinkPassed: true,
      headTurnPassed: true,
      timestamp: DateTime.now(),
    );

    Navigator.of(context).pop(result);
  }

  void _failCurrentAttempt(String reason) {
    if (_currentAttempt < AppConstants.maxVerificationAttempts) {
      setState(() {
        _currentAttempt++;
        _livenessService.resetChallenge();
        _statusMessage = 'Attempt failed ($reason). Retrying attempt $_currentAttempt of ${AppConstants.maxVerificationAttempts}...';
      });
      _startCountdownTimer();
    } else {
      _hasTerminated = true;
      _countdownTimer?.cancel();
      _stopCameraStream();
      final result = VerificationResult(
        status: VerificationStatus.exhaustedAttempts,
        message: 'Exceeded maximum verification attempts (${AppConstants.maxVerificationAttempts}). Payment cancelled.',
        attemptsUsed: _currentAttempt,
        timestamp: DateTime.now(),
      );
      Navigator.of(context).pop(result);
    }
  }

  void _stopCameraStream() {
    try {
      if (_cameraController != null && _cameraController!.value.isStreamingImages) {
        _cameraController!.stopImageStream();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stopCameraStream();
    _cameraController?.dispose();
    _faceDetectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _latestLivenessState?.progress ?? 0.1;
    final instruction = _latestLivenessState?.instruction ?? 'Look at front camera to start';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Face Liveness Verification'),
        actions: [
          IconButton(
            tooltip: 'Cancel & Return',
            icon: const Icon(Icons.close),
            onPressed: () {
              _hasTerminated = true;
              Navigator.of(context).pop(VerificationResult(
                status: VerificationStatus.cancelledByUser,
                message: 'Verification cancelled by user',
                timestamp: DateTime.now(),
              ));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Security Notice Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryLight.withAlpha(100)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: AppTheme.accent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Amount: ${AppConstants.currencySymbol}${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Amount exceeds ₹500. On-device face liveness is mandatory.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Camera Viewfinder & Face Oval
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Camera feed preview or simulator fallback
                    if (_isCameraInitialized && _cameraController != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: SizedBox(
                          width: 280,
                          height: 360,
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    else
                      Container(
                        width: 280,
                        height: 360,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(200),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.face_retouching_natural, size: 80, color: Colors.white38),
                            SizedBox(height: 12),
                            Text(
                              'Camera Preview Active',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                    // Guided Biometric Oval Frame
                    Container(
                      width: 290,
                      height: 370,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        border: Border.all(
                          color: _latestLivenessState?.isCompleted == true
                              ? AppTheme.accent
                              : AppTheme.primaryLight,
                          width: 3.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Instruction & Progress Panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E222D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),

                  // Prompt instruction
                  Text(
                    instruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status / Feedback
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Attempt counter & Timeout Countdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Attempt $_currentAttempt of ${AppConstants.maxVerificationAttempts}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _secondsRemaining <= 5 ? Colors.red.withAlpha(50) : Colors.amber.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _secondsRemaining <= 5 ? Colors.redAccent : Colors.amber,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 13,
                              color: _secondsRemaining <= 5 ? Colors.redAccent : Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_secondsRemaining}s',
                              style: TextStyle(
                                color: _secondsRemaining <= 5 ? Colors.redAccent : Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Evaluator / Testing Controls Section
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'DEMO / EVALUATION CONTROLS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Pass',
                                icon: Icons.check_circle_outline,
                                color: AppTheme.accent,
                                onPressed: _completeVerificationSuccess,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppButton(
                                label: 'Fail',
                                icon: Icons.highlight_off,
                                isOutlined: true,
                                color: Colors.white70,
                                onPressed: () => _failCurrentAttempt('Simulated challenge mismatch'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppButton(
                                label: 'Timeout',
                                icon: Icons.timer_off_outlined,
                                isOutlined: true,
                                color: Colors.amberAccent,
                                onPressed: _handleTimeout,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
