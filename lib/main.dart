import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase backend services asynchronously
  await FirebaseService.initialize();

  runApp(const FacePayApp());
}

class FacePayApp extends StatelessWidget {
  const FacePayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FacePay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
