import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../utils/polyline_decoder.dart';

class RouteModel {
  final List<LatLng> points;
  final String distance;
  final String duration;
  RouteModel({required this.points, required this.distance, required this.duration});
}

class DirectionsService {
  static Future<RouteModel?> getRoutePoints(LatLng origin, LatLng destination, String apiKey) async {
    final originStr = '${origin.latitude},${origin.longitude}';
    final destStr = '${destination.latitude},${destination.longitude}';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originStr&destination=$destStr&key=$apiKey&mode=driving');
    try {
      final resp = await http.get(url);
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      if (data['status'] != 'OK') return null;
      final route = data['routes'][0];
      final leg = route['legs'][0];
      final poly = route['overview_polyline']['points'] as String;
      final points = PolylineDecoder.decodePolyline(poly);
      final dist = leg['distance']['text'] as String;
      final dur = leg['duration']['text'] as String;
      return RouteModel(points: points, distance: dist, duration: dur);
    } catch (e) {
      return null;
    }
  }
}
