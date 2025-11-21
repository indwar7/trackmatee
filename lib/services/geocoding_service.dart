import 'package:geocoding/geocoding.dart';

class GeocodingService {
  static Future<({double lat, double lng})?> getCoordinatesFromAddress(
      String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;

      final loc = locations.first;

      return (lat: loc.latitude, lng: loc.longitude);
    } catch (e) {
      print("Geocoding error: $e");
      return null;
    }
  }

  static Future<String?> getAddressFromCoordinates(
      double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      return "${place.street}, ${place.locality}, ${place.administrativeArea}";
    } catch (e) {
      print("Reverse geocoding error: $e");
      return null;
    }
  }
}
