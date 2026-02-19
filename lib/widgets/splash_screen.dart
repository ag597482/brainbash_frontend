import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Small delay to ensure splash is visible
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // Router will handle navigation via redirect logic
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            Image.asset(
              'assets/images/brainbash_logo.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(
                  duration: 1000.ms,
                  color: Colors.white.withOpacity(0.3),
                ),
          ],
        ),
      ),
    );
  }
}
