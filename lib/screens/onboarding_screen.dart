import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isFromSettings;
  const OnboardingScreen({super.key, this.isFromSettings = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.qr_code_scanner,
      'title': 'Scan. Verify. Pay.',
      'subtitle': 'The next generation of UPI payment security. Fast everyday payments combined with advanced biometric defense against unauthorized transfers.',
      'color': AppTheme.primary,
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Smart ₹500 Threshold Rule',
      'subtitle': 'Micro-payments of ₹500 or less process instantly without friction. Any transaction above ₹500 strictly enforces on-device facial liveness verification.',
      'color': AppTheme.accent,
    },
    {
      'icon': Icons.lock_outline,
      'title': 'Zero-Cloud Biometric Privacy',
      'subtitle': 'All computer vision and facial liveness checks execute locally via Google ML Kit. No face photos, camera frames, or biometric vectors ever leave your device.',
      'color': const Color(0xFF6366F1),
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    if (widget.isFromSettings) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkHeader,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.face_retouching_natural, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FacePay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text('Skip', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: (page['color'] as Color).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: (page['color'] as Color).withValues(alpha: 0.4), width: 2),
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 60,
                            color: page['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppTheme.primary : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      icon: _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward,
                      onPressed: _onNext,
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
