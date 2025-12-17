import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
// import 'screens/scan_screen.dart';
import 'screens/leaf_detail_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/learn_leaf_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/register_screen.dart';
import 'screens/scan_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LeafyApp());
}

class LeafyApp extends StatelessWidget {
  const LeafyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/scan': (context) => const ScanScreen(),
        '/leaf-detail': (context) => const LeafDetailScreen(),
        '/achievement': (context) => const AchievementScreen(),
        '/learn-leaf': (context) => const LearnLeafScreen(),
      },
    );
  }
}
