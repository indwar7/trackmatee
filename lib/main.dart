// =============================================================
//                      TRACKMATE - MAIN APP
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// =============== CONTROLLERS ===============
import 'package:trackmate_app/controllers/profile_controller.dart';
import 'package:trackmate_app/controllers/language_controller.dart';
import 'package:trackmate_app/controllers/location_controller.dart';
import 'package:trackmate_app/controllers/saved_places_controller.dart';
import 'package:trackmate_app/controllers/trusted_contacts_controller.dart';

// =============== SERVICES ===============
import 'package:trackmate_app/services/auth_service.dart';
import 'package:trackmate_app/services/localization_service.dart';

// =============== ONBOARDING ===============
import 'package:trackmate_app/screens/onboarding/splash_screen.dart';
import 'package:trackmate_app/screens/onboarding/permissions_screen.dart';
import 'package:trackmate_app/screens/onboarding/terms_of_use_screen.dart';
import 'package:trackmate_app/screens/onboarding/home_screen.dart';

// =============== AUTH ===============
import 'package:trackmate_app/screens/auth/login_screen.dart';
import 'package:trackmate_app/screens/auth/signup_screen.dart';
import 'package:trackmate_app/screens/auth/forgot_password_screen.dart';
import 'package:trackmate_app/screens/auth/forgot_otp_screen.dart';
import 'package:trackmate_app/screens/auth/reset_password_screen.dart';
import 'package:trackmate_app/screens/auth/otp_verification.dart';
import 'package:trackmate_app/screens/auth/otp_verification_reset.dart';

// =============== MAIN SCREENS ===============
import 'package:trackmate_app/screens/analytics/analytics_screen.dart';
import 'package:trackmate_app/screens/bookings/booking_screen.dart';
import 'package:trackmate_app/screens/planner_screen.dart';
import 'package:trackmate_app/screens/discover/discover_screen.dart';
import 'package:trackmate_app/screens/maps_screen.dart';

// =============== USER ===============
import 'package:trackmate_app/screens/user/profile_screen.dart';
import 'package:trackmate_app/screens/user/settings_screen.dart';
import 'package:trackmate_app/screens/user/support_screen.dart';
import 'package:trackmate_app/screens/user/trusted_contacts_screen.dart';
import 'package:trackmate_app/screens/user/vehicle_info_screen.dart';
import 'package:trackmate_app/screens/user/edit_profile_screen.dart';

// =============== VERIFICATION ===============
import 'package:trackmate_app/screens/verification/user_verification_screen.dart';
import 'package:trackmate_app/screens/aadhaar_verification_screen.dart';
import 'package:trackmate_app/screens/capture_id_screen.dart';
import 'package:trackmate_app/screens/id_capture_tips_screen.dart';
import 'package:trackmate_app/screens/verification/id_status_screen.dart';

// =============== TRIPS ===============
import 'package:trackmate_app/screens/trips/maps_screen.dart' as TripsMap;
import 'package:trackmate_app/screens/trips/trip_history_screen.dart';

// =============== TOOLS ===============
import 'package:trackmate_app/screens/tools/safety_tools_screen.dart';
import 'package:trackmate_app/screens/tools/invite_friends_screen.dart';

// =============== PLACES ===============
import 'package:trackmate_app/screens/places/location_search_screen.dart';
import 'package:trackmate_app/screens/places/add_work_screen.dart';

// =============================================================
//                           ENTRY POINT
// =============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await dotenv.load();

  Get.put(AuthService(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.lazyPut(() => LanguageController());
  Get.lazyPut(() => LocationController());
  Get.lazyPut(() => SavedPlacesController());
  Get.lazyPut(() => TrustedContactsController());

  runApp(const TrackMateApp());
}

// =============================================================
//                        ROOT APP
// =============================================================

class TrackMateApp extends StatelessWidget {
  const TrackMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "TrackMate",
      debugShowCheckedModeBanner: false,
      translations: LocalizationService(),
      locale: LocalizationService.fallbackLocale,
      fallbackLocale: const Locale('en','US'),

      initialRoute: "/",
      theme: ThemeData.dark(useMaterial3: true),
      defaultTransition: Transition.fadeIn,

      getPages: [

        GetPage(name:"/", page:()=> const SplashScreen()),
        GetPage(name:"/permissions", page:()=> const LocationPermissionScreen()),
        GetPage(name:"/terms", page:()=> const TermsOfUseScreen()),
        GetPage(name:"/home", page:()=> const HomeScreen()),

        GetPage(name:"/login", page:()=> const LoginScreen()),
        GetPage(name:"/signup", page:()=> SignUpScreen()),
        GetPage(name:"/otp", page:()=> const OtpVerificationScreen()),
        GetPage(name:"/otp-reset", page:()=> const OtpVerificationResetScreen()),
        GetPage(name:"/forgot-password", page:()=> const ForgotPasswordScreen()),
        GetPage(name:"/forgot-otp", page:()=> const ForgotOtpVerifyScreen()),
        GetPage(name:"/reset-password", page:()=> const ResetPasswordScreen()),

        GetPage(name:"/analytics", page:()=> const AnalyticsScreen()),
        GetPage(name:"/discover", page:()=> const DiscoverScreen()),
        GetPage(name:"/bookings", page:()=> const BookingScreen()),
        GetPage(name:"/planner", page:()=> const PlannerScreen()),
        GetPage(name:"/maps", page:()=> const MapsScreen()),

        GetPage(name:"/profile", page:()=> const ProfileScreen()),
        GetPage(name:"/settings", page:()=> const SettingsScreen()),
        GetPage(name:"/support", page:()=> const SupportScreen()),
        GetPage(name:"/trusted-contacts", page:()=> const TrustedContactsScreen()),
        GetPage(name:"/vehicle-info", page:()=> const VehicleInfoScreen()),
        GetPage(name:"/edit-profile", page:()=> const EditProfileScreen()),

        GetPage(name:"/user-verification", page:()=> const UserVerificationScreen()),
        GetPage(name:"/aadhaar", page:()=> const AadhaarVerificationScreen()),
        GetPage(name:"/capture-id", page:()=> CaptureIdScreen(isFront:true)),
        GetPage(name:"/id-tips", page:()=> const IdCaptureTipsScreen()),


        GetPage(name:"/trip-history", page:()=> const TripHistoryScreen()),
        GetPage(name:"/live-trip", page:()=> const TripsMap.MapsScreen()),

        GetPage(name:"/safety-tools", page:()=> const SafetyToolsScreen()),
        GetPage(name:"/invite", page:()=> const InviteFriendsScreen()),

        GetPage(name:"/search-location", page:()=> const LocationSearchScreen()),
        GetPage(name:"/add-work", page:()=> const AddWorkScreen()),
      ],
    );
  }
}

class IdStatusScreen {
  const IdStatusScreen();
}
