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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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

    // Navigate after delay
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    final authService = Get.find<AuthService>();

    // If logged in → go to home
    if (authService.isLoggedIn) {
      Get.offAllNamed('/home');
      return;
    }

    final hasCompletedOnboarding =
        _storage.read('onboarding_completed') ?? false;

    if (hasCompletedOnboarding) {
      // Returning user → permissions → login
      Get.offAllNamed('/permissions');
    } else {
      // First-time user → welcome
      Get.offAllNamed('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF2A2A3E),
              Color(0xFF8B5CF6),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon / Logo
              Image.asset(
                'assets/Rectangle.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 80,
                      color: Color(0xFF8B5CF6),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'WELCOME TRAVELLER',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,  // ✅ FIXED
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

              // Loader
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