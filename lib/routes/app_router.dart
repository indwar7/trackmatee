import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// PROVIDERS
import '../providers/auth_provider.dart';

// AUTH SCREENS
import '../screens/aadhaar_verification_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification.dart';
import '../screens/auth/otp_verification_reset.dart';

// ID VERIFICATION
import '../screens/capture_id_screen.dart';
import '../screens/id_capture_tips_screen.dart';
import '../screens/verification/user_verification_screen.dart';

// MAIN
import '../screens/dashboard_screen.dart';
import '../screens/trips/maps_screen.dart';
import '../screens/trips/trip_maps_screen.dart';

import 'app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();

      final allowed = [
        AppRoutes.login,
        AppRoutes.otpVerification,
        AppRoutes.otpVerificationReset
      ];

      if (!authProvider.isAuthenticated &&
          !allowed.contains(state.matchedLocation)) {
        return AppRoutes.login;
      }

      if (authProvider.isAuthenticated &&
          state.matchedLocation == AppRoutes.login) {
        return AppRoutes.dashboard;
      }
      return null;
    },

    routes: [

      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),

      // SIGNUP OTP
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (_, __) => const OtpVerificationScreen(), // ✔ class name matched
      ),

      // RESET OTP
      GoRoute(
        path: AppRoutes.otpVerificationReset,
        builder: (_, __) => const OtpVerificationResetScreen(),
      ),

      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),

      GoRoute(
        path: AppRoutes.idCaptureTips,
        builder: (_, __) => const IdCaptureTipsScreen(),
      ),

      GoRoute(
        path: AppRoutes.captureId,
        builder: (_, __) => const CaptureIdScreen(isFront: true),
      ),

      GoRoute(
        path: AppRoutes.aadharVerification,
        builder: (_, __) => const AadhaarVerificationScreen(),
      ),

      GoRoute(
        path: AppRoutes.userVerification,
        builder: (_, __) => const UserVerificationScreen(),
      ),

      GoRoute(
        path: AppRoutes.mapsScreen,
        builder: (_, __) => const MapsScreen(),
      ),

      GoRoute(
        path: AppRoutes.tripMapsScreen,
        builder: (_, __) => const TripMapsScreen(),
      ),
    ],
  );
}
