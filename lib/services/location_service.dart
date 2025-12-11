import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const String _apiKey = "AIzaSyA6uK1raTG6fNpw5twxbX0tfveW6Rd5YNE";

  /// =====================================================
  /// CURRENT LOCATION
  /// =====================================================
  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// =====================================================
  /// GET ADDRESS FROM COORDINATES
  /// =====================================================
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json"
          "?latlng=$lat,$lng&key=$_apiKey",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data["results"].isEmpty) return "Unknown location";
    return data["results"][0]["formatted_address"];
  }

  /// =====================================================
  /// AUTOCOMPLETE SEARCH → returns List<Map<String,dynamic>>
  /// =====================================================
  static Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?input=$query&key=$_apiKey&components=country:in",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (!data.containsKey("predictions")) return [];

    return List<Map<String, dynamic>>.from(
      data["predictions"].map((p) {
        return {
          "place_id": p["place_id"],
          "name": p["description"],
        };
      }),
    );
  }


  /// ==============================================
  /// CHECK PERMISSIONS
  /// ==============================================
  static Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// ==============================================
  /// POSITION STREAM (REAL-TIME LIVE TRACKING)
  /// ==============================================
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // meters
      ),
    );
  }


  /// =====================================================
  /// PLACE DETAILS → returns {lat,lng,name}
  /// =====================================================
  static Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
          "?place_id=$placeId&fields=name,geometry&key=$_apiKey",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (!data.containsKey("result")) return {};

    final result = data["result"];
    final loc = result["geometry"]["location"];

    return {
      "name": result["name"],
      "lat": loc["lat"],
      "lng": loc["lng"],
    };
  }
}