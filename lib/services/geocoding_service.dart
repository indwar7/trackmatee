import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationResult {
  final double lat;
  final double lng;
  final String? name;

  LocationResult({required this.lat, required this.lng, this.name});
}

class GeocodingService {
  // Replace with your API key or keep it in AndroidManifest and fetch securely
  static const String _apiKey = 'AIzaSyCIuctlZtylqWYpH8NZ_y8hdqQ0P5JhlHM';

  // returns LocationResult or null
  static Future<LocationResult?> getCoordinatesFromAddress(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=$encoded&key=$_apiKey');

    try {
      final resp = await http.get(url);
      if (resp.statusCode != 200) return null;
      final data = json.decode(resp.body);
      if (data['status'] != 'OK') return null;

      final first = data['results'][0];
      final loc = first['geometry']['location'];
      final name = first['formatted_address'] as String?;
      return LocationResult(lat: (loc['lat'] as num).toDouble(), lng: (loc['lng'] as num).toDouble(), name: name);
    } catch (e) {
      // handle errors
      return null;
    }
  }
}
