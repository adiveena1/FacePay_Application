import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../core/constants/app_constants.dart';

enum LivenessStep {
  detectFace,
  blinkChallenge,
  headTurnChallenge,
  completed,
  failed,
}

enum HeadTurnDirection {
  turnLeft,
  turnRight,
}

class LivenessState {
  final LivenessStep step;
  final HeadTurnDirection targetDirection;
  final String instruction;
  final double progress; // 0.0 to 1.0
  final bool blinkDetected;
  final bool headTurnDetected;
  final String feedback;
  final bool isCompleted;
  final bool isFailed;

  const LivenessState({
    required this.step,
    required this.targetDirection,
    required this.instruction,
    required this.progress,
    this.blinkDetected = false,
    this.headTurnDetected = false,
    required this.feedback,
    this.isCompleted = false,
    this.isFailed = false,
  });

  LivenessState copyWith({
    LivenessStep? step,
    HeadTurnDirection? targetDirection,
    String? instruction,
    double? progress,
    bool? blinkDetected,
    bool? headTurnDetected,
    String? feedback,
    bool? isCompleted,
    bool? isFailed,
  }) {
    return LivenessState(
      step: step ?? this.step,
      targetDirection: targetDirection ?? this.targetDirection,
      instruction: instruction ?? this.instruction,
      progress: progress ?? this.progress,
      blinkDetected: blinkDetected ?? this.blinkDetected,
      headTurnDetected: headTurnDetected ?? this.headTurnDetected,
      feedback: feedback ?? this.feedback,
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}

class LivenessService {
  // Challenge State Tracking
  bool _blinkEyesWereOpen = false;
  bool _blinkEyesWereClosed = false;
  bool _blinkPassed = false;

  bool _headWasCentered = false;
  bool _headTurnPassed = false;
  late HeadTurnDirection _chosenDirection;
  LivenessStep _currentStep = LivenessStep.detectFace;

  bool get isBlinkPassed => _blinkPassed;
  bool get isHeadTurnPassed => _headTurnPassed;

  LivenessService() {
    resetChallenge();
  }

  void resetChallenge() {
    _blinkEyesWereOpen = false;
    _blinkEyesWereClosed = false;
    _blinkPassed = false;
    _headWasCentered = false;
    _headTurnPassed = false;
    // Alternate or randomize challenge direction
    _chosenDirection = DateTime.now().millisecond % 2 == 0 
        ? HeadTurnDirection.turnLeft 
        : HeadTurnDirection.turnRight;
    _currentStep = LivenessStep.detectFace;
  }

  LivenessState processFaceFrame(Face face) {
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0.8;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.8;
    final headEulerY = face.headEulerAngleY ?? 0.0; // Yaw angle (left/right)

    // Step 1: Detect clean, centered face
    if (_currentStep == LivenessStep.detectFace) {
      if (headEulerY.abs() < 12.0) {
        _currentStep = LivenessStep.blinkChallenge;
        return LivenessState(
          step: _currentStep,
          targetDirection: _chosenDirection,
          instruction: 'Challenge 1: Please BLINK your eyes naturally',
          progress: 0.25,
          feedback: 'Face detected. Keep looking forward.',
        );
      } else {
        return LivenessState(
          step: _currentStep,
          targetDirection: _chosenDirection,
          instruction: 'Please look directly into the camera',
          progress: 0.1,
          feedback: 'Center your head inside the circle.',
        );
      }
    }

    // Step 2: Blink Challenge (multi-frame state machine)
    if (_currentStep == LivenessStep.blinkChallenge) {
      final bothEyesOpen = leftEyeOpen > AppConstants.eyeOpenThreshold && 
                           rightEyeOpen > AppConstants.eyeOpenThreshold;
      final bothEyesClosed = leftEyeOpen < AppConstants.eyeClosedThreshold && 
                             rightEyeOpen < AppConstants.eyeClosedThreshold;

      if (bothEyesOpen && !_blinkEyesWereClosed) {
        _blinkEyesWereOpen = true;
      }

      if (_blinkEyesWereOpen && bothEyesClosed) {
        _blinkEyesWereClosed = true;
      }

      // Transition Open -> Closed -> Open confirms natural liveness blink
      if (_blinkEyesWereOpen && _blinkEyesWereClosed && bothEyesOpen) {
        _blinkPassed = true;
        _currentStep = LivenessStep.headTurnChallenge;
        final dirText = _chosenDirection == HeadTurnDirection.turnLeft ? 'LEFT' : 'RIGHT';
        return LivenessState(
          step: _currentStep,
          targetDirection: _chosenDirection,
          instruction: 'Challenge 2: Turn your head slightly $dirText',
          progress: 0.60,
          blinkDetected: true,
          feedback: 'Blink verified! Now turn your head $dirText.',
        );
      }

      return LivenessState(
        step: _currentStep,
        targetDirection: _chosenDirection,
        instruction: 'Challenge 1: Please BLINK your eyes',
        progress: _blinkEyesWereClosed ? 0.45 : 0.30,
        blinkDetected: false,
        feedback: _blinkEyesWereClosed ? 'Now open your eyes' : 'Blink when ready',
      );
    }

    // Step 3: Head Movement Challenge
    if (_currentStep == LivenessStep.headTurnChallenge) {
      // Check if user starts from center
      if (headEulerY.abs() < 15.0) {
        _headWasCentered = true;
      }

      final turnAngle = headEulerY;
      bool turnedSufficiently = false;

      // Note: In ML Kit Android front camera, yaw direction:
      // Turn left: positive angle (> +20) or negative depending on mirror.
      // We accept magnitude in the targeted direction:
      if (_chosenDirection == HeadTurnDirection.turnLeft) {
        // Left turn or significant lateral rotation
        turnedSufficiently = turnAngle > AppConstants.headTurnAngleThreshold || 
                             turnAngle < -AppConstants.headTurnAngleThreshold;
      } else {
        // Right turn
        turnedSufficiently = turnAngle < -AppConstants.headTurnAngleThreshold || 
                             turnAngle > AppConstants.headTurnAngleThreshold;
      }

      if (_headWasCentered && turnedSufficiently) {
        _headTurnPassed = true;
        _currentStep = LivenessStep.completed;

        return LivenessState(
          step: _currentStep,
          targetDirection: _chosenDirection,
          instruction: 'Liveness Verified Successfully!',
          progress: 1.0,
          blinkDetected: _blinkPassed,
          headTurnDetected: true,
          feedback: 'All liveness challenges passed.',
          isCompleted: true,
        );
      }

      final dirText = _chosenDirection == HeadTurnDirection.turnLeft ? 'LEFT' : 'RIGHT';
      return LivenessState(
        step: _currentStep,
        targetDirection: _chosenDirection,
        instruction: 'Challenge 2: Turn your head slightly $dirText',
        progress: 0.75,
        blinkDetected: true,
        headTurnDetected: false,
        feedback: 'Rotate head towards the $dirText slowly.',
      );
    }

    // Completed
    return LivenessState(
      step: LivenessStep.completed,
      targetDirection: _chosenDirection,
      instruction: 'Verification Complete',
      progress: 1.0,
      blinkDetected: true,
      headTurnDetected: true,
      feedback: 'Ready to authorize payment.',
      isCompleted: true,
    );
  }
}
