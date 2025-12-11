import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  /// SEARCH PLACES USING KEY
  static Future<List<Map<String, dynamic>>> searchLocationWithKey(
      String query,
      String apiKey,
      ) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?input=$query"
          "&key=$apiKey"
          "&components=country:in",
    );

    try {
      final res = await http.get(url);
      final data = jsonDecode(res.body);

      if (data["status"] == "OK") {
        final list = data["predictions"] ?? [];
        return List<Map<String, dynamic>>.from(
          list.map((p) => {
            "place_id": p["place_id"],
            "name": p["structured_formatting"]["main_text"],
            "description": p["description"],
          }),
        );
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// GET PLACE DETAILS USING KEY
  static Future<Map<String, dynamic>> getPlaceDetailsWithKey(
      String placeId,
      String apiKey,
      ) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
          "?place_id=$placeId"
          "&key=$apiKey",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data["status"] == "OK") {
      final r = data["result"];
      return {
        "name": r["name"],
        "lat": r["geometry"]["location"]["lat"],
        "lng": r["geometry"]["location"]["lng"],
      };
    }
    return {};
  }

  /// CONVERT COORDINATES TO ADDRESS
  static Future<String> getAddressFromCoordinates(
      double lat,
      double lng,
      ) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json"
          "?latlng=$lat,$lng"
          "&key=AIzaSyCIuctlZtylqWYpH8NZ_y8hdqQ0P5JhlHM", // Geocoding key
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data["status"] == "OK" && data["results"].isNotEmpty) {
      return data["results"][0]["formatted_address"];
    }
    return "Unknown location";
  }
}
