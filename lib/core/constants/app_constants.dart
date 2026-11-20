/// Global constants for the FacePay application
class AppConstants {
  static const String appName = 'FacePay';
  static const String appTagline = 'Privacy-First Face Authentication for Secure Digital Payments';
  static const String currencySymbol = '₹';

  // Payment Verification Threshold Rule
  // Amounts > 500.00 require face liveness verification
  static const double faceVerificationThreshold = 500.00;

  // Liveness Verification Challenge Constants
  static const int maxVerificationAttempts = 3;
  static const int challengeTimeoutSeconds = 15;
  static const double eyeClosedThreshold = 0.25;
  static const double eyeOpenThreshold = 0.70;
  static const double headTurnAngleThreshold = 20.0; // degrees yaw for turning head left/right

  // Simulated Account Data
  static const double defaultInitialBalance = 25000.00;
  static const String defaultUserName = 'Aditya Veena Maharaj';
  static const String defaultUserUpiId = 'aditya.maharaj@facepay';

  // Shared Preferences Keys
  static const String prefKeyBalance = 'facepay_wallet_balance';
  static const String prefKeyTransactions = 'facepay_transactions_json';
  static const String prefKeyRewards = 'facepay_user_rewards';
  static const String prefKeyThreshold = 'facepay_verification_threshold';
}
