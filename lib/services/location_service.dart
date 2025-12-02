import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Ensure location permissions
  static Future<bool> ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    // Request permission if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Permanently denied
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // If only while-in-use is granted, try to request full (Android 10+)
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Wrapper to check permissions
  static Future<bool> checkPermissions() async {
    return await ensureLocationPermission();
  }

  /// Get current location
  static Future<Position> getCurrentLocation() async {
    bool allowed = await ensureLocationPermission();
    if (!allowed) {
      throw Exception("Location permissions not granted");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Live location stream
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  /// Convert coordinates to a human-readable address
  static Future<String> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isEmpty) return "Unknown Address";

    final p = placemarks.first;

    return "${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.country}";
  }
}
