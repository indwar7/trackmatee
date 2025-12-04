// =============================================================
//                      TRACKMATE - MAIN APP
// =============================================================
import 'package:provider/provider.dart';
import 'package:trackmate_app/services/api_service.dart';
import 'package:trackmate_app/services/location_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// ================= SERVICES =================
import 'package:trackmate_app/services/auth_service.dart';

// ================= CONTROLLERS ==============
import 'package:trackmate_app/controllers/profile_controller.dart';
import 'package:trackmate_app/controllers/language_controller.dart';
import 'package:trackmate_app/controllers/location_controller.dart';

// ================= ONBOARDING ================
import 'package:trackmate_app/screens/onboarding/splash_screen.dart';
import 'package:trackmate_app/screens/onboarding/welcome_screen.dart';
import 'package:trackmate_app/screens/onboarding/permissions_screen.dart';
import 'package:trackmate_app/screens/onboarding/terms_of_use_screen.dart';
import 'package:trackmate_app/screens/onboarding/main_navigation_screen.dart';

// ================= MAIN SCREENS =============
import 'package:trackmate_app/screens/discover/discover_screen.dart';
import 'package:trackmate_app/screens/map_screen.dart';
import 'package:trackmate_app/screens/my_stats_screen.dart';
import 'package:trackmate_app/screens/chat_screen/chat_screen.dart';
import 'package:trackmate_app/screens/ai_checklist_screen.dart';
import 'package:trackmate_app/screens/cost_calculator_screen.dart';

// ================= TRIP & MAP =================
import 'package:trackmate_app/screens/live_tracking_screen.dart';
import 'package:trackmate_app/screens/manual_trip_screen.dart';
import 'package:trackmate_app/screens/planned_trip_screen.dart';
import 'package:trackmate_app/screens/saved_planned_trips_screen.dart';
import 'package:trackmate_app/screens/trip_summary_screen.dart';
import 'package:trackmate_app/screens/trip_history_screen.dart';
import 'package:trackmate_app/screens/trip_end_form_screen.dart';

// ================= USER =====================
import 'package:trackmate_app/screens/user/profile_screen.dart' as UserProfile;
import 'package:trackmate_app/screens/user/settings_screen.dart';
import 'package:trackmate_app/screens/user/support_screen.dart';
import 'package:trackmate_app/screens/user/trusted_contacts_screen.dart';
import 'package:trackmate_app/screens/user/vehicle_info_screen.dart';
import 'package:trackmate_app/screens/user/edit_profile_screen.dart';

// ================= VERIFICATION =============
import 'package:trackmate_app/screens/verification/user_verification_screen.dart';
import 'package:trackmate_app/screens/aadhaar_verification_screen.dart';
import 'package:trackmate_app/screens/capture_id_screen.dart';
import 'package:trackmate_app/screens/id_capture_tips_screen.dart';
import 'package:trackmate_app/screens/verification/id_status_screen.dart';

// ================= TOOLS ====================
import 'package:trackmate_app/screens/tools/safety_tools_screen.dart';
import 'package:trackmate_app/screens/tools/invite_friends_screen.dart';

// ================= LOCATIONS =================
import 'package:trackmate_app/screens/location_search_screen.dart';
import 'package:trackmate_app/screens/edit_address_screen.dart';
import 'package:trackmate_app/screens/places/add_work_screen.dart';


// =============================================================
//                           ENTRY POINT
// =============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  /// Load .env
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint("⚠️ .env not loaded => $e");
  }

  // Register global controllers
  Get.put(AuthService(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(LocationController(), permanent: true);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
      ],
      child: const TrackMateApp(),
    ),
  );
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
      initialRoute: "/",
      fallbackLocale: const Locale('en', 'US'),

      theme: ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: const Color(0xFF8B5CF6),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213e),
          elevation: 0,
        ),
      ),

      // =============================================================
      //                          ROUTES
      // =============================================================
      getPages: [

        /// ---------------- ONBOARDING ----------------
        GetPage(name: "/", page: () => const SplashScreen()),
        GetPage(name: "/welcome", page: () => const WelcomeScreen()),
        GetPage(name: "/permissions", page: () => const LocationPermissionScreen()),
        GetPage(name: "/terms", page: () => const TermsOfUseScreen()),
        GetPage(name: "/home", page: () => const MainNavigationScreen()),

        /// ---------------- MAIN ----------------------
        GetPage(name: "/discover", page: () => const DiscoverScreen()),
        GetPage(name: "/my-stats", page: () => const MyStatsScreen()),
        GetPage(name: "/ai-chatbot", page: () => ChatScreen()),
        GetPage(name: "/ai-checklist", page: () => const AiChecklistScreen()),
        GetPage(name: "/cost-calculator", page: () => const CostCalculatorScreen()),

        /// ============================================================
        ///                       TRIP & MAP
        /// ============================================================

        // MAP — Start trip button
        GetPage(
          name: "/map",
          page: () => const MapScreen(),
        ),

        // LIVE TRACKING — Auto trip tracking
        GetPage(
          name: "/live-tracking",
          page: () {
            final args = Get.arguments as Map<String, dynamic>? ?? {};
            return LiveTrackingScreen(
              tripId: args['tripId'] ?? 0,
              startLocation: args['startLocation'] ?? '',
            );
          },
        ),

        // TRIP HISTORY BUTTON
        GetPage(
          name: "/trip-history",
          page: () => const TripHistoryScreen(),
        ),

        // RECORD A TRIP BUTTON
        GetPage(
          name: "/saved-planned-trips",
          page: () => const SavedPlannedTripsScreen(),
        ),

        // SCHEDULE TRIP FOR LATER BUTTON
        GetPage(
          name: "/manual-trip",
          page: () => const ManualTripScreen(),
        ),

        // OPTIONAL TRIP SUMMARY
        GetPage(
          name: "/trip-summary",
          page: () {
            final args = Get.arguments as Map<String, dynamic>? ?? {};
            return TripSummaryScreen(data: args);
          },
        ),

        // OPTIONAL TRIP END FORM
        GetPage(
          name: "/trip-summary",
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;

            return TripSummaryScreen(
              data: args ?? {},
            );
          },
        ),

        /// ============================================================
        ///                          USER
        /// ============================================================
        GetPage(name: "/profile", page: () => const UserProfile.ProfileScreen()),
        GetPage(name: "/edit-profile", page: () => const EditProfileScreen()),
        GetPage(name: "/settings", page: () => const SettingsScreen()),
        GetPage(name: "/support", page: () => const SupportScreen()),
        GetPage(name: "/trusted-contacts", page: () => TrustedContactsScreen()),
        GetPage(name: "/vehicle-info", page: () => const VehicleInfoScreen()),

        /// ============================================================
        ///                      VERIFICATION
        /// ============================================================
        GetPage(name: "/user-verification", page: () => const UserVerificationScreen()),
        GetPage(name: "/aadhaar", page: () => const AadhaarVerificationScreen()),
        GetPage(name: "/capture-id", page: () => const CaptureIdScreen(isFront: true)),
        GetPage(name: "/id-tips", page: () => const IdCaptureTipsScreen()),
        GetPage(name: "/id-status", page: () => const IdStatusScreen()),

        /// ============================================================
        ///                          TOOLS
        /// ============================================================
        GetPage(name: "/safety-tools", page: () => const SafetyToolsScreen()),
        GetPage(name: "/invite", page: () => const InviteFriendsScreen()),

        /// ============================================================
        ///                        LOCATIONS
        /// ============================================================
        GetPage(name: "/location-search", page: () => const LocationSearchScreen()),
        GetPage(name: "/edit-address", page: () => const EditAddressScreen()),
        GetPage(name: "/add-work", page: () => const AddWorkScreen()),
      ],
    );
  }
}
