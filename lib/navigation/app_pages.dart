import 'package:get/get.dart';
import 'package:trackmate_app/screens/onboarding/home_screen.dart';
import 'package:trackmate_app/screens/analytics/analytics_screen.dart';
import 'package:trackmate_app/screens/bookings/booking_screen.dart';
import 'package:trackmate_app/screens/planner_screen.dart';
import 'package:trackmate_app/screens/user/profile_screen.dart';
import 'package:trackmate_app/screens/auth/login_screen.dart';
import 'package:trackmate_app/screens/auth/signup_screen.dart';
import 'package:trackmate_app/screens/auth/forgot_password_screen.dart';
import 'package:trackmate_app/screens/auth/reset_password_screen.dart';
import 'package:trackmate_app/screens/auth/forgot_otp_screen.dart';     // 🔥 REQUIRED FOR FORGOT PASSWORD FLOW
import 'package:trackmate_app/screens/maps_screen.dart';
import 'package:trackmate_app/screens/onboarding/splash_screen.dart';
import 'package:trackmate_app/screens/onboarding/welcome_screen.dart';

import 'package:trackmate_app/screens/onboarding/terms_of_use_screen.dart';

import 'package:trackmate_app/screens/user/settings_screen.dart';
import 'package:trackmate_app/screens/user/support_screen.dart';
import 'package:trackmate_app/screens/user/trusted_contacts_screen.dart';
import 'package:trackmate_app/screens/verification/user_verification_screen.dart';
import 'package:trackmate_app/screens/capture_id_screen.dart';
import 'package:trackmate_app/screens/id_capture_tips_screen.dart';
import 'package:trackmate_app/screens/verification/id_status_screen.dart';
import 'package:trackmate_app/screens/onboarding/permissions_screen.dart';

class AppPages {
  static const initial = '/splash';

  static final routes = [

    // ---------------- Onboarding ----------------
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/welcome', page: () => const WelcomeScreen()),
    // GetPage(name: '/language-selection', page: () => const LanguageSelectionScreen()),
    GetPage(name: '/permissions', page: () => const LocationPermissionScreen()),   // 🔥 FIXED
    GetPage(name: '/terms', page: () => const TermsOfUseScreen()),

    // ---------------- AUTH ROUTES ----------------
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/signup', page: () => const SignUpScreen()),
    GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
    GetPage(name: '/forgot-otp', page: () => const ForgotOtpVerifyScreen()),    // 🔥 ADDED
    GetPage(name: '/reset-password', page: () => const ResetPasswordScreen()),

    // ---------------- MAIN APP ROUTES ----------------
    GetPage(name: '/home', page: () => const HomeScreen()),
    GetPage(name: '/analytics', page: () => const AnalyticsScreen()),
    GetPage(name: '/bookings', page: () => const BookingScreen()),
    GetPage(name: '/planner', page: () => const PlannerScreen()),
    GetPage(name: '/maps', page: () => const MapsScreen()),

    // ---------------- TRAVEL ----------------
    // GetPage(name: '/travel', page: () => const TravelHomeScreen()),
    // GetPage(name: '/flights', page: () => const FlightsScreen()),
    // GetPage(name: '/hotels', page: () => const HotelsScreen()),
    // GetPage(name: '/tours', page: () => const ToursScreen()),

    // ---------------- USER ----------------
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(name: '/settings', page: () => const SettingsScreen()),
    GetPage(name: '/support', page: () => const SupportScreen()),
    GetPage(name: '/trusted-contacts', page: () => const TrustedContactsScreen()),

    // ---------------- VERIFICATION ----------------
    GetPage(name: '/verification', page: () => const UserVerificationScreen()),
    GetPage(
      name: '/capture-id',
      page: () => CaptureIdScreen(isFront: Get.arguments ?? true),
    ),
    GetPage(name: '/id-tips', page: () => const IdCaptureTipsScreen()),
    GetPage(name: '/id-status', page: () => const IdStatusScreen()),
    GetPage(name: '/id-tips', page: () => const IdCaptureTipsScreen()),
    GetPage(name: '/id-status', page: () => const IdStatusScreen()),
  ];
}
