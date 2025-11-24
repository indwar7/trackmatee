import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesService {
  static const apiKey = "AIzaSyCvuze7W6e4S_5bSAEuX9K0GJCPMvvVNTQ";

  static Future<List<Map<String, dynamic>>> autocomplete(String input) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    return (data["predictions"] as List).map((d) {
      return {
        "description": d["description"],
        "place_id": d["place_id"]
      };
    }).toList();
  }

  static Future<LatLng> getPlaceLatLng(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final loc = jsonDecode(res.body)["result"]["geometry"]["location"];

    return LatLng(loc["lat"], loc["lng"]);
  }
}
