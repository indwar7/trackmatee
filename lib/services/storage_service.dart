import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kLastDestination = 'last_destination';

  static Future<void> saveDestination(LatLng loc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastDestination, jsonEncode({'lat': loc.latitude, 'lng': loc.longitude}));
  }

  static Future<LatLng?> loadDestination() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kLastDestination);
    if (s == null) return null;
    final map = jsonDecode(s);
    return LatLng((map['lat'] as num).toDouble(), (map['lng'] as num).toDouble());
  }
}
