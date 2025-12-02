import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://56.228.42.249/api';

  String? authToken;

  void setToken(String token) {
    authToken = token;
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // Start Trip
  Future<Map<String, dynamic>> startTrip({
    required double startLat,
    required double startLng,
    String? locationName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trips/start/'),
      headers: headers,
      body: jsonEncode({
        'start_latitude': double.parse(startLat.toStringAsFixed(6)),
        'start_longitude': double.parse(startLng.toStringAsFixed(6)),
        'start_location_name': locationName,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start trip: ${response.statusCode} ${response.body}');
    }
  }

  // Add Tracking Point
  Future<void> addTrackingPoint({
    required int tripId,
    required double lat,
    required double lng,
    required double accuracy,
    double? speed,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trips/$tripId/add-tracking-point/'),
      headers: headers,
      body: jsonEncode({
        'latitude': double.parse(lat.toStringAsFixed(6)),
        'longitude': double.parse(lng.toStringAsFixed(6)),
        'accuracy': accuracy,
        'speed': speed,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add tracking point: ${response.statusCode} ${response.body}');
    }
  }

  // End Trip
  Future<Map<String, dynamic>> endTrip({
    required int tripId,
    required double endLat,
    required double endLng,
    String? endLocationName,
    String? modeOfTravel,
    String? tripPurpose,
    int? companions,
    double? fuelExpense,
    double? parkingCost,
    double? tollCost,
    double? ticketCost,
    String? fuelType,
    double? co2Emitted,
    double? totalCost,
  }) async {
    final body = {
      'end_latitude': double.parse(endLat.toStringAsFixed(6)),
      'end_longitude': double.parse(endLng.toStringAsFixed(6)),
      if (endLocationName != null) 'end_location_name': endLocationName,
      if (modeOfTravel != null) 'mode_of_travel': modeOfTravel,
      if (tripPurpose != null) 'trip_purpose': tripPurpose,
      if (companions != null) 'number_of_companions': companions,
      if (fuelExpense != null) 'fuel_expense': fuelExpense,
      if (parkingCost != null) 'parking_cost': parkingCost,
      if (tollCost != null) 'toll_cost': tollCost,
      if (ticketCost != null) 'ticket_cost': ticketCost,
      if (fuelType != null) 'fuel_type': fuelType,
      if (co2Emitted != null) 'co2_emitted': co2Emitted,
      if (totalCost != null) 'total_cost': totalCost,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/trips/$tripId/end/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to end trip: ${response.statusCode} ${response.body}');
    }
  }

  // Get Ongoing Trip (defensive)
  Future<Map<String, dynamic>?> getOngoingTrip() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips/ongoing/'),
      headers: headers,
    );

    // treat unauthorized as no ongoing trip
    if (response.statusCode == 401 || response.statusCode == 403) {
      return null;
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded == null) return null;
      if (decoded is Map<String, dynamic>) {
        // direct trip object
        if (decoded.containsKey('id') && (decoded['id'] is int || decoded['id'] is String)) {
          if (_looksActive(decoded)) return decoded;
          return null;
        }
        // nested trip
        if (decoded.containsKey('trip') && decoded['trip'] is Map<String, dynamic>) {
          final trip = decoded['trip'] as Map<String, dynamic>;
          if (trip.containsKey('id') && (trip['id'] is int || trip['id'] is String)) {
            if (_looksActive(trip)) return trip;
            return null;
          }
        }
        // sometimes returns flags with id
        if ((decoded.containsKey('is_active') || decoded.containsKey('status')) && decoded.containsKey('id')) {
          if (_looksActive(decoded)) return decoded;
        }
      }
      // shape not recognized -> treat as no ongoing trip
      return null;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to get ongoing trip: ${response.statusCode} ${response.body}');
    }
  }

  bool _looksActive(Map<String, dynamic> trip) {
    if (trip.containsKey('status') && trip['status'] is String) {
      final s = (trip['status'] as String).toLowerCase();
      if (s == 'ongoing' || s == 'in_progress' || s == 'active') return true;
    }
    if (trip.containsKey('is_active')) {
      final ia = trip['is_active'];
      if (ia is bool && ia) return true;
      if (ia is String && ia.toLowerCase() == 'true') return true;
    }
    return false;
  }

  // Create Manual Trip
  Future<Map<String, dynamic>> createManualTrip({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startLocation,
    String? endLocation,
    String? tripDate,
    String? modeOfTravel,
    String? tripPurpose,
    int? companions,
    double? fuelExpense,
    double? parkingCost,
    double? tollCost,
    double? ticketCost,
  }) async {
    final body = {
      'start_latitude': double.parse(startLat.toStringAsFixed(6)),
      'start_longitude': double.parse(startLng.toStringAsFixed(6)),
      'end_latitude': double.parse(endLat.toStringAsFixed(6)),
      'end_longitude': double.parse(endLng.toStringAsFixed(6)),
      if (startLocation != null) 'start_location': startLocation,
      if (endLocation != null) 'end_location': endLocation,
      if (tripDate != null) 'trip_date': tripDate,
      if (modeOfTravel != null) 'mode_of_travel': modeOfTravel,
      if (tripPurpose != null) 'trip_purpose': tripPurpose,
      if (companions != null) 'number_of_companions': companions,
      if (fuelExpense != null) 'fuel_expense': fuelExpense,
      if (parkingCost != null) 'parking_cost': parkingCost,
      if (tollCost != null) 'toll_cost': tollCost,
      if (ticketCost != null) 'ticket_cost': ticketCost,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/trips/create-manual/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create manual trip: ${response.statusCode} ${response.body}');
    }
  }

  // Create Planned Trip
  Future<Map<String, dynamic>> createPlannedTrip({
    required String tripName,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startLocation,
    String? endLocation,
    required String startDate,
    String? endDate,
    String? modeOfTravel,
    String? tripPurpose,
    String? description,
    int? companions,
    double? estimatedBudget,
  }) async {
    final body = {
      'trip_name': tripName,
      'start_latitude': double.parse(startLat.toStringAsFixed(6)),
      'start_longitude': double.parse(startLng.toStringAsFixed(6)),
      'end_latitude': double.parse(endLat.toStringAsFixed(6)),
      'end_longitude': double.parse(endLng.toStringAsFixed(6)),
      'start_date': startDate,
      if (startLocation != null) 'start_location': startLocation,
      if (endLocation != null) 'end_location': endLocation,
      if (endDate != null) 'end_date': endDate,
      if (modeOfTravel != null) 'mode_of_travel': modeOfTravel,
      if (tripPurpose != null) 'trip_purpose': tripPurpose,
      if (description != null) 'description': description,
      if (companions != null) 'number_of_companions': companions,
      if (estimatedBudget != null) 'estimated_budget': estimatedBudget,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/trips/create-planned/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create planned trip: ${response.statusCode} ${response.body}');
    }
  }

  // Get Trip History
  Future<List<Map<String, dynamic>>> getTripHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips/history/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['trips'] != null) {
        return List<Map<String, dynamic>>.from(data['trips']);
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to get trip history: ${response.statusCode} ${response.body}');
    }
  }

  // Preview Route
  Future<Map<String, dynamic>> previewRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String mode = 'car',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trips/preview-route/'),
      headers: headers,
      body: jsonEncode({
        'start_latitude': double.parse(startLat.toStringAsFixed(6)),
        'start_longitude': double.parse(startLng.toStringAsFixed(6)),
        'end_latitude': double.parse(endLat.toStringAsFixed(6)),
        'end_longitude': double.parse(endLng.toStringAsFixed(6)),
        'mode_of_travel': mode,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to preview route: ${response.statusCode} ${response.body}');
    }
  }
}