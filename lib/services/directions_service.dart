import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsResult {
  final List<LatLng> points;
  final String distance;
  final String duration;

  DirectionsResult({
    required this.points,
    required this.distance,
    required this.duration,
  });
}

class DirectionsService {
  static const String apiKey = "AIzaSyDFTdr7PpBNjhE6yufD7mRfLu5yEoIV9SI";

  static Future<DirectionsResult> getRoutePoints(
      LatLng origin, LatLng dest) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final route = data["routes"][0];
    final leg = route["legs"][0];

    final distance = leg["distance"]["text"];
    final duration = leg["duration"]["text"];

    final polyline =
    route["overview_polyline"]["points"];
    final points = _decodePolyline(polyline);

    return DirectionsResult(
      points: points,
      distance: distance,
      duration: duration,
    );
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return polyline;
  }
}
