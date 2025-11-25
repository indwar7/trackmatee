import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Controllers
import 'package:trackmate_app/controllers/language_controller.dart';
import 'package:trackmate_app/controllers/location_controller.dart';
import 'package:trackmate_app/controllers/saved_places_controller.dart';
import 'package:trackmate_app/controllers/trusted_contacts_controller.dart';

// Services
import 'package:trackmate_app/services/localization_service.dart';
import 'package:trackmate_app/services/auth_service.dart';

// Widgets
import 'package:trackmate_app/widgets/auth_wrapper.dart';

// Screens - Auth
import 'package:trackmate_app/screens/onboarding/splash_screen.dart';
import 'package:trackmate_app/screens/user/profile_screen.dart';
import 'package:trackmate_app/screens/auth/signup_screen.dart';
import 'package:trackmate_app/screens/auth/login_screen.dart';
import 'package:trackmate_app/screens/auth/forgot_password_screen.dart';
import 'package:trackmate_app/screens/auth/phone_otp_screen.dart';
import 'package:trackmate_app/screens/auth/reset_password_screen.dart';

// Screens - Main
import 'package:trackmate_app/screens/home_screen.dart';
import 'package:trackmate_app/screens/analytics/analytics_screen.dart';
import 'package:trackmate_app/screens/bookings/booking_screen.dart';
import 'package:trackmate_app/screens/planner_screen.dart';
import 'package:trackmate_app/screens/discover_screen.dart';
import 'package:trackmate_app/screens/user/settings_screen.dart';
import 'package:trackmate_app/screens/user/support_screen.dart';
import 'package:trackmate_app/screens/user/trusted_contacts_screen.dart';

// Screens - Travel
import 'package:trackmate_app/screens/travel/travel_booking_screens.dart';

// Screens - Places
import 'package:trackmate_app/screens/places/location_search_screen.dart';
import 'package:trackmate_app/screens/places/add_work_screen.dart';

// Screens - Verification
import 'package:trackmate_app/screens/verification/user_verification_screen.dart';
import 'package:trackmate_app/screens/capture_id_screen.dart';
import 'package:trackmate_app/screens/id_capture_tips_screen.dart';

// Screens - Trips
import 'package:trackmate_app/screens/trips/trip_history_screen.dart';

// Screens - Tools
import 'package:trackmate_app/screens/tools/safety_tools_screen.dart';

// Screens - Onboarding
import 'package:trackmate_app/screens/onboarding/terms_of_use_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize GetStorage first
    await GetStorage.init();
    debugPrint('GetStorage initialized successfully');
    
    // Initialize services
    await initializeServices();
    
    // Initialize auth service
    await initAuthService();
    
    runApp(const TrackMateApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    rethrow; // This will show the error in the console
  }
}

Future<void> initializeServices() async {
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Environment variables loaded successfully");
    debugPrint("Loaded env: ${dotenv.env}");
    debugPrint("Google Translate API Key: ${dotenv.env['google_translate_api_key'] != null}");
  } catch (e) {
    debugPrint("Failed to load .env: $e");
  }

  await LocalizationService.init();

  Get.lazyPut(() => LanguageController(), fenix: true);
  Get.lazyPut(() => LocationController(), fenix: true);
  Get.lazyPut(() => SavedPlacesController(), fenix: true);
  Get.lazyPut(() => TrustedContactsController(), fenix: true);
}

class TrackMateApp extends StatelessWidget {
  const TrackMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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

      // Internationalization
      translations: LocalizationService(),
      locale: Locale(Get.find<LanguageController>().currentLang.value),
      fallbackLocale: LocalizationService.fallbackLocale,
      supportedLocales:
      LocalizationService.supportedLanguages.keys.map((lang) => Locale(lang)).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Use SplashScreen as the initial route
      home: const SplashScreen(),
      getPages: [
        // Auth Routes
        GetPage(name: '/signup', page: () => const SignUpScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
        GetPage(name: '/reset-password', page: () => const ResetPasswordScreen()),
        GetPage(name: '/phone-otp', page: () => const PhoneOtpScreen()),
        
        // Main Tabs
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/analytics', page: () => const AnalyticsScreen()),
        GetPage(name: '/bookings', page: () => const BookingScreen()),
        GetPage(name: '/planner', page: () => const PlannerScreen()),
        GetPage(name: '/discover', page: () => const DiscoverScreen()),
        
        // User Profile
        GetPage(name: '/profile', page: () => ProfileScreen(), fullscreenDialog: true),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/support', page: () => const SupportScreen()),
        GetPage(name: '/trusted-contacts', page: () => const TrustedContactsScreen()),
        
        // Travel & Places
        GetPage(name: '/travel-booking', page: () => const TravelBookingScreen()),
        GetPage(name: '/location-search', page: () => const LocationSearchScreen()),
        GetPage(name: '/add-work', page: () => const AddWorkScreen()),
        
        // Verification
        GetPage(name: '/user-verification', page: () => const UserVerificationScreen()),
        GetPage(
          name: '/capture-id', 
          page: () => const CaptureIdScreen(isFront: true, frontImage: null),
        ),
        GetPage(name: '/id-capture-tips', page: () => const IdCaptureTipsScreen()),
        
        // Trips & Tools
        GetPage(name: '/trip-history', page: () => const TripHistoryScreen()),
        GetPage(name: '/safety-tools', page: () => const SafetyToolsScreen()),
        
        // Onboarding
        GetPage(name: '/terms-of-use', page: () => const TermsOfUseScreen()),
      ],
    );
  }
}
