import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionStatus {
  final int faceCount;
  final bool hasSingleFace;
  final Face? primaryFace;
  final String message;

  const FaceDetectionStatus({
    required this.faceCount,
    required this.hasSingleFace,
    this.primaryFace,
    required this.message,
  });
}

class FaceDetectionService {
  FaceDetector? _faceDetector;

  void initializeDetector() {
    final options = FaceDetectorOptions(
      enableClassification: true, // Needed for eye open probabilities (blink)
      enableLandmarks: true,      // Landmark verification
      enableContours: false,
      enableTracking: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<FaceDetectionStatus> processImage(InputImage inputImage) async {
    if (_faceDetector == null) {
      initializeDetector();
    }

    try {
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        return const FaceDetectionStatus(
          faceCount: 0,
          hasSingleFace: false,
          primaryFace: null,
          message: 'No face detected. Please position your face inside the frame.',
        );
      }

      if (faces.length > 1) {
        return FaceDetectionStatus(
          faceCount: faces.length,
          hasSingleFace: false,
          primaryFace: null,
          message: 'Multiple faces detected (${faces.length}). Only one user allowed for verification.',
        );
      }

      // Exactly one face
      return FaceDetectionStatus(
        faceCount: 1,
        hasSingleFace: true,
        primaryFace: faces.first,
        message: 'Face detected cleanly.',
      );
    } catch (e) {
      return FaceDetectionStatus(
        faceCount: 0,
        hasSingleFace: false,
        primaryFace: null,
        message: 'Detection error: $e',
      );
    }
  }

  void dispose() {
    _faceDetector?.close();
    _faceDetector = null;
  }
}
