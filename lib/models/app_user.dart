/// User profile data model for FacePay authentication and session management
class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final bool isBiometricEnrolled;
  final bool isDemoAccount;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.isBiometricEnrolled = true,
    this.isDemoAccount = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'phoneNumber': phoneNumber,
    'isBiometricEnrolled': isBiometricEnrolled,
    'isDemoAccount': isDemoAccount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    displayName: json['displayName'] as String? ?? 'User',
    email: json['email'] as String? ?? '',
    phoneNumber: json['phoneNumber'] as String?,
    isBiometricEnrolled: json['isBiometricEnrolled'] as bool? ?? true,
    isDemoAccount: json['isDemoAccount'] as bool? ?? true,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}
