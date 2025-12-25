import 'package:flutter/material.dart';
import '../../shared/bottom_nav_bar.dart';
import '../Database/prefs_service.dart';
import 'onboarding_screen.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _init(BuildContext context) async {
    final prefs = await PrefsService.getInstance();
    final seen = prefs.getSeenOnboarding();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => seen ? const BottomNavBar() : OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) => _init(context));

    return Scaffold(
      body: Center(
        child: Icon(
          Icons.account_balance_wallet_rounded,
          size: 100,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

