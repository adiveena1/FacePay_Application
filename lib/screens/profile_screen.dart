import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of FacePay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, size: 36, color: AppTheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.defaultUserName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkHeader,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'adityaveena1@gmail.com',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Verified Biometric Account',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security & Device Section
          const Text(
            'Security & Biometrics',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.face_retouching_natural, color: AppTheme.primary),
                  title: const Text('Face Liveness Verification'),
                  subtitle: const Text('Enforced on amounts > ₹500'),
                  trailing: const Icon(Icons.check_circle, color: AppTheme.accent),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security, color: Color(0xFF6366F1)),
                  title: const Text('Biometric Privacy Mode'),
                  subtitle: const Text('Zero-Cloud: On-Device Processing'),
                  trailing: const Icon(Icons.lock, color: AppTheme.accent, size: 20),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_done_outlined, color: Colors.orange),
                  title: const Text('Cloud Firestore Sync'),
                  subtitle: const Text('Project: facepayapplication'),
                  trailing: const Icon(Icons.check, color: AppTheme.accent, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Guide & Policies
          const Text(
            'Project & Legal',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.primary),
                  title: const Text('How FacePay Works'),
                  subtitle: const Text('View the 3-step onboarding walkthrough'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(isFromSettings: true),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.accent),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('https://facepayapplication1.vercel.app/privacy-policy'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy URL: https://facepayapplication1.vercel.app/privacy-policy'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.school_outlined, color: Color(0xFF6366F1)),
                  title: Text('Academic Project PBL-3 (CSP-391)'),
                  subtitle: Text('Aditya Veena Maharaj & Gaurav Mudgal • Supervised by Dr. Gaurav Raj (Sharda University)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sign out button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.error,
              side: const BorderSide(color: AppTheme.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
