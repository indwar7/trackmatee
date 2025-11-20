import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/terms_of_use_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/phone_otp_screen.dart';

void main() {
  runApp(const TrackMateApp());
}

class TrackMateApp extends StatelessWidget {
  const TrackMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF8B5CF6),
          surface: const Color(0xFF16213E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
      ),
      initialRoute: '/splash',
      routes: {

        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/terms': (context) => const TermsOfUseScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp-verification': (context) => const OTPVerificationScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/phoneOtp': (context) => const PhoneOtpScreen(),
      },
    );
  }
}
