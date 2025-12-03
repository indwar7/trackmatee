// 📌 lib/screens/onboarding/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trackmate_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();

    // Setup animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate after 3 seconds
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Wait for 3 seconds (splash duration)
    await Future.delayed(const Duration(seconds: 3));

    // Get auth service
    final authService = Get.find<AuthService>();

    // Check if user is logged in
    if (authService.isLoggedIn) {
      // Logged in user → Go to Home directly
      Get.offAllNamed('/home');
      return;
    }

    // Check if onboarding is completed
    final hasCompletedOnboarding = _storage.read('onboarding_completed') ?? false;

    if (hasCompletedOnboarding) {
      // Returning user (onboarding done but not logged in)
      // → Go to Permissions then Login
      Get.offAllNamed('/permissions');
    } else {
      // First time user → Go to Welcome Screen
      Get.offAllNamed('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              // Image.asset(
              //   'assets/logo.png',
              //   width: 150,
              //   height: 150,
              //   errorBuilder: (context, error, stackTrace) {
              //     return Container(
              //       width: 150,
              //       height: 150,
              //       decoration: BoxDecoration(
              //         color: const Color(0xFF8B5CF6).withOpacity(0.2),
              //         shape: BoxShape.circle,
              //       ),
              //       child: const Icon(
              //         Icons.location_on,
              //         size: 80,
              //         color: Color(0xFF8B5CF6),
              //       ),
              //     );
              //   },
              // ),
              const SizedBox(height: 30),

              // App Name
              const Text(
                'WELCOME TRAVELLER',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),

              // Tagline
              const Text(
                'Your Smart Travel Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 60),

              // Loading Indicator
              const SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: Color(0xFF8B5CF6),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}