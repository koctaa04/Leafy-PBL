import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/leaf_detail_screen.dart';
import 'screens/achievement_screen.dart';

void main() {
  runApp(const LeafLearnApp());
}

class LeafLearnApp extends StatelessWidget {
  const LeafLearnApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/scan': (context) => const ScanScreen(),
        '/leaf-detail': (context) => const LeafDetailScreen(),
        '/achievement': (context) => const AchievementScreen(),
      },
    );
  }
}
