import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../screens/maps_screen.dart';
import '../services/auth_service.dart';

// AUTH SCREENS
import '../screens/aadhaar_verification_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification.dart';
import '../screens/auth/otp_verification_reset.dart';

// ID VERIFICATION
import '../screens/capture_id_screen.dart';
import '../screens/id_capture_tips_screen.dart';
import '../screens/verification/user_verification_screen.dart';

// MAIN SCREENS
import '../screens/onboarding/home_screen.dart';

class AppRoutes {
  // ---------------- ROUTE NAMES ----------------
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String otpVerificationReset = '/otp-verification-reset';
  static const String home = '/home';
  static const String idCaptureTips = '/id-tips';
  static const String captureId = '/capture-id';
  static const String aadharVerification = '/aadhaar-verification';
  static const String userVerification = '/user-verification';
  static const String mapsScreen = '/maps';

  // ---------------- ROUTES ----------------
  static final List<GetPage> routes = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: otpVerification, page: () => const OtpVerificationScreen()),
    GetPage(name: otpVerificationReset, page: () => const OtpVerificationResetScreen()),
    GetPage(name: home, page: () => const HomeScreen()),

    // ID Verification
    GetPage(name: idCaptureTips, page: () => const IdCaptureTipsScreen()),
    GetPage(name: captureId, page: () => CaptureIdScreen(isFront: true)),
    GetPage(name: aadharVerification, page: () => const AadhaarVerificationScreen()),
    GetPage(name: userVerification, page: () => const UserVerificationScreen()),

    // Maps
    GetPage(name: mapsScreen, page: () => const MapsScreen()),
  ];
}

// ---------------- AUTH GUARD ----------------
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final auth = Get.find<AuthService>();

      return auth.isLoggedIn
          ? null
          : const RouteSettings(name: AppRoutes.login);

    } catch (_) {
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}
