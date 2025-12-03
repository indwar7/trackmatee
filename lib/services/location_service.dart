import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  // Replace with your actual Google Maps API key
  static const String _googleApiKey = "AIzaSyCvuze7W6e4S_5bSAEuX9K0GJCPMvvVNTQ";

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
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return "Unknown Address";

      final p = placemarks.first;

      // Build address string with available components
      List<String> addressParts = [];

      if (p.street != null && p.street!.isNotEmpty) {
        addressParts.add(p.street!);
      }
      if (p.subLocality != null && p.subLocality!.isNotEmpty) {
        addressParts.add(p.subLocality!);
      }
      if (p.locality != null && p.locality!.isNotEmpty) {
        addressParts.add(p.locality!);
      }
      if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
        addressParts.add(p.administrativeArea!);
      }
      if (p.country != null && p.country!.isNotEmpty) {
        addressParts.add(p.country!);
      }

      return addressParts.isNotEmpty
          ? addressParts.join(', ')
          : "Unknown Address";
    } catch (e) {
      print("Error getting address: $e");
      return "Unknown Address";
    }
  }

  /// Search for locations using Google Places Autocomplete API
  static Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    if (query.isEmpty || query.length < 3) {
      print("LocationService: Search query too short: '$query'");
      return [];
    }

    try {
      print("LocationService: Searching for: '$query'");

      // Get autocomplete predictions
      final autocompleteUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
              'input=${Uri.encodeComponent(query)}&'
              'key=$_googleApiKey'
        // Remove country restriction or change as needed
        // '&components=country:in'
      );

      print("LocationService: Autocomplete URL: $autocompleteUrl");

      final autocompleteResponse = await http.get(autocompleteUrl).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("LocationService: Request timed out");
          throw Exception('Search request timed out');
        },
      );

      print("LocationService: Autocomplete response status: ${autocompleteResponse.statusCode}");
      print("LocationService: Response body: ${autocompleteResponse.body}");

      if (autocompleteResponse.statusCode != 200) {
        print("LocationService: Autocomplete API error: ${autocompleteResponse.statusCode}");
        print("LocationService: Response body: ${autocompleteResponse.body}");
        return [];
      }

      final autocompleteData = json.decode(autocompleteResponse.body);
      print("LocationService: Autocomplete status: ${autocompleteData['status']}");

      if (autocompleteData['status'] == 'REQUEST_DENIED') {
        print("LocationService: API Key error: ${autocompleteData['error_message']}");
        return [];
      }

      if (autocompleteData['status'] != 'OK' && autocompleteData['status'] != 'ZERO_RESULTS') {
        print("LocationService: Autocomplete status: ${autocompleteData['status']}");
        if (autocompleteData['error_message'] != null) {
          print("LocationService: Error message: ${autocompleteData['error_message']}");
        }
        return [];
      }

      if (autocompleteData['predictions'] == null || autocompleteData['predictions'].isEmpty) {
        print("LocationService: No predictions found");
        return [];
      }

      print("LocationService: Found ${autocompleteData['predictions'].length} predictions");

      List<Map<String, dynamic>> results = [];

      // Get details for each prediction
      for (var prediction in autocompleteData['predictions']) {
        final placeId = prediction['place_id'];
        final description = prediction['description'];

        print("LocationService: Fetching details for: $description");

        // Get place details to fetch coordinates
        final detailsUrl = Uri.parse(
            'https://maps.googleapis.com/maps/api/place/details/json?'
                'place_id=$placeId&'
                'fields=geometry&'
                'key=$_googleApiKey'
        );

        try {
          final detailsResponse = await http.get(detailsUrl).timeout(
            const Duration(seconds: 10),
          );

          print("LocationService: Details response status: ${detailsResponse.statusCode}");

          if (detailsResponse.statusCode == 200) {
            final detailsData = json.decode(detailsResponse.body);

            print("LocationService: Details status: ${detailsData['status']}");

            if (detailsData['status'] == 'OK' && detailsData['result'] != null) {
              final location = detailsData['result']['geometry']['location'];

              // FIX: Handle both int and double types from API
              final lat = (location['lat'] is int)
                  ? (location['lat'] as int).toDouble()
                  : location['lat'] as double;

              final lng = (location['lng'] is int)
                  ? (location['lng'] as int).toDouble()
                  : location['lng'] as double;

              results.add({
                'name': description,
                'lat': lat,
                'lng': lng,
                'placeId': placeId,
              });

              print("LocationService: ✓ Added location: $description ($lat, $lng)");
            } else {
              print("LocationService: Invalid details response: ${detailsData['status']}");
            }
          } else {
            print("LocationService: Details request failed: ${detailsResponse.statusCode}");
          }
        } catch (e) {
          print("LocationService: Error fetching details for $description: $e");
          continue;
        }

        // Limit to 5 results to avoid too many API calls
        if (results.length >= 5) {
          print("LocationService: Reached limit of 5 results");
          break;
        }
      }

      print("LocationService: ✓ Total results found: ${results.length}");
      return results;
    } catch (e) {
      print("LocationService: ✗ Error searching location: $e");
      print("LocationService: Stack trace: ${StackTrace.current}");
      return [];
    }
  }

  /// Alternative: Search using Geocoding (offline, less accurate)
  static Future<List<Map<String, dynamic>>> searchLocationOffline(String query) async {
    try {
      print("LocationService: Offline search for: $query");

      List<Location> locations = await locationFromAddress(query);

      print("LocationService: Found ${locations.length} offline locations");

      List<Map<String, dynamic>> results = [];

      for (var location in locations) {
        // Get address for each location
        String address = await getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );

        results.add({
          'name': address,
          'lat': location.latitude,
          'lng': location.longitude,
        });

        print("LocationService: Added offline result: $address");

        // Limit results
        if (results.length >= 5) break;
      }

      return results;
    } catch (e) {
      print("LocationService: Error in offline search: $e");
      return [];
    }
  }

  /// Get coordinates from address string
  static Future<Map<String, dynamic>?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) return null;

      final location = locations.first;

      return {
        'lat': location.latitude,
        'lng': location.longitude,
      };
    } catch (e) {
      print("LocationService: Error getting coordinates from address: $e");
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
  }

  /// Calculate bearing between two points
  static double calculateBearing(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }
}