import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://56.228.42.249:8000/api';

  String? authToken;

  void setToken(String token) {
    authToken = token;
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  // ========== TRIP TRACKING APIs ==========

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
        if (locationName != null) 'start_location_name': locationName,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start trip: ${response.statusCode} ${response.body}');
    }
  }

  // Add Tracking Point
  Future<Map<String, dynamic>> addTrackingPoint({
    required int tripId,
    required double lat,
    required double lng,
    required double accuracy,
    double? speed,
    String? timestamp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/trips/$tripId/add-tracking-point/'),
      headers: headers,
      body: jsonEncode({
        'latitude': double.parse(lat.toStringAsFixed(6)),
        'longitude': double.parse(lng.toStringAsFixed(6)),
        'accuracy': accuracy,
        if (speed != null) 'speed': speed,
        if (timestamp != null) 'timestamp': timestamp,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Failed to add tracking point: ${response.statusCode} ${response.body}'
      );
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

  // Get Ongoing Trip
  Future<Map<String, dynamic>?> getOngoingTrip() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips/ongoing/'),
      headers: headers,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      return null;
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded == null) return null;
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('id') && (decoded['id'] is int || decoded['id'] is String)) {
          if (_looksActive(decoded)) return decoded;
          return null;
        }
        if (decoded.containsKey('trip') && decoded['trip'] is Map<String, dynamic>) {
          final trip = decoded['trip'] as Map<String, dynamic>;
          if (trip.containsKey('id') && (trip['id'] is int || trip['id'] is String)) {
            if (_looksActive(trip)) return trip;
            return null;
          }
        }
        if ((decoded.containsKey('is_active') || decoded.containsKey('status')) && decoded.containsKey('id')) {
          if (_looksActive(decoded)) return decoded;
        }
      }
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

  // Get Trip History
  Future<Map<String, dynamic>> getTripHistory({
    String? dateFrom,
    String? dateTo,
    String? mode,
    String? purpose,
    String? ordering,
  }) async {
    final queryParams = <String, String>{};
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;
    if (mode != null) queryParams['mode'] = mode;
    if (purpose != null) queryParams['purpose'] = purpose;
    if (ordering != null) queryParams['ordering'] = ordering;

    final uri = Uri.parse('$baseUrl/trips/history/').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is List) {
        return {'count': data.length, 'trips': data};
      }
      return {'count': 0, 'trips': []};
    } else {
      throw Exception('Failed to get trip history: ${response.statusCode} ${response.body}');
    }
  }

  // Get Specific Trip Details
  Future<Map<String, dynamic>> getTripDetails(int tripId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips/$tripId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get trip details: ${response.statusCode} ${response.body}');
    }
  }

  // Update Trip Details
  Future<Map<String, dynamic>> updateTripDetails({
    required int tripId,
    String? modeOfTravel,
    String? tripPurpose,
    int? companions,
    double? fuelExpense,
    double? parkingCost,
    double? tollCost,
    double? ticketCost,
  }) async {
    final body = <String, dynamic>{};
    if (modeOfTravel != null) body['mode_of_travel'] = modeOfTravel;
    if (tripPurpose != null) body['trip_purpose'] = tripPurpose;
    if (companions != null) body['number_of_companions'] = companions;
    if (fuelExpense != null) body['fuel_expense'] = fuelExpense;
    if (parkingCost != null) body['parking_cost'] = parkingCost;
    if (tollCost != null) body['toll_cost'] = tollCost;
    if (ticketCost != null) body['ticket_cost'] = ticketCost;

    final response = await http.patch(
      Uri.parse('$baseUrl/trips/$tripId/update-details/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update trip details: ${response.statusCode} ${response.body}');
    }
  }

  // ========== MANUAL TRIP APIs ==========

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

  // Preview Route
  Future<Map<String, dynamic>> previewRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startLocationName,
    String? endLocationName,
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
        if (startLocationName != null) 'start_location_name': startLocationName,
        if (endLocationName != null) 'end_location_name': endLocationName,
        'mode_of_travel': mode,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to preview route: ${response.statusCode} ${response.body}');
    }
  }

  // ========== PLANNED TRIPS APIs ==========

  // List All Planned Trips
  Future<List<Map<String, dynamic>>> getPlannedTrips({
    String? status,
    String? ordering,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (ordering != null) queryParams['ordering'] = ordering;

    final uri = Uri.parse('$baseUrl/planned-trips/').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } else {
      throw Exception('Failed to get planned trips: ${response.statusCode} ${response.body}');
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
    String? estimatedDistance,
    int? estimatedDuration,
    List<Map<String, dynamic>>? waypoints,
    String? notes,
    String? routePolyline,
  }) async {
    final body = {
      'trip_name': tripName,
      'start_latitude': double.parse(startLat.toStringAsFixed(6)),
      'start_longitude': double.parse(startLng.toStringAsFixed(6)),
      'destination_latitude': double.parse(endLat.toStringAsFixed(6)),
      'destination_longitude': double.parse(endLng.toStringAsFixed(6)),
      'planned_start_date': startDate,
      if (startLocation != null) 'start_location_name': startLocation,
      if (endLocation != null) 'destination_name': endLocation,
      if (endDate != null) 'planned_end_date': endDate,
      if (modeOfTravel != null) 'mode_of_travel': modeOfTravel,
      if (tripPurpose != null) 'trip_purpose': tripPurpose,
      if (description != null) 'description': description,
      if (companions != null) 'number_of_companions': companions,
      if (estimatedBudget != null) 'estimated_budget': estimatedBudget,
      if (estimatedDistance != null) 'estimated_distance_km': estimatedDistance,
      if (estimatedDuration != null) 'estimated_duration_minutes': estimatedDuration,
      if (waypoints != null) 'waypoints': waypoints,
      if (notes != null) 'notes': notes,
      if (routePolyline != null) 'route_polyline': routePolyline,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/planned-trips/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create planned trip: ${response.statusCode} ${response.body}');
    }
  }

  // Get Specific Planned Trip
  Future<Map<String, dynamic>> getPlannedTripDetails(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/planned-trips/$id/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get planned trip: ${response.statusCode} ${response.body}');
    }
  }

  // Update Planned Trip (Full Update)
  Future<Map<String, dynamic>> updatePlannedTrip(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/planned-trips/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update planned trip: ${response.statusCode} ${response.body}');
    }
  }

  // Partial Update Planned Trip
  Future<Map<String, dynamic>> patchPlannedTrip(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/planned-trips/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to patch planned trip: ${response.statusCode} ${response.body}');
    }
  }

  // Delete Planned Trip
  Future<void> deletePlannedTrip(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/planned-trips/$id/'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete planned trip: ${response.statusCode} ${response.body}');
    }
  }

  // Get Upcoming Trips
  Future<List<Map<String, dynamic>>> getUpcomingTrips() async {
    final response = await http.get(
      Uri.parse('$baseUrl/planned-trips/upcoming/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } else {
      throw Exception('Failed to get upcoming trips: ${response.statusCode} ${response.body}');
    }
  }

  // Start Trip from Planned Trip
  Future<Map<String, dynamic>> startPlannedTrip({
    required int plannedTripId,
    double? startLat,
    double? startLng,
    String? startLocationName,
  }) async {
    final body = <String, dynamic>{};
    if (startLat != null) body['start_latitude'] = double.parse(startLat.toStringAsFixed(6));
    if (startLng != null) body['start_longitude'] = double.parse(startLng.toStringAsFixed(6));
    if (startLocationName != null) body['start_location_name'] = startLocationName;

    final response = await http.post(
      Uri.parse('$baseUrl/planned-trips/$plannedTripId/start_trip/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start planned trip: ${response.statusCode} ${response.body}');
    }
  }

  // Cancel Planned Trip
  Future<Map<String, dynamic>> cancelPlannedTrip(int id, {String? reason}) async {
    final body = <String, dynamic>{};
    if (reason != null) body['reason'] = reason;

    final response = await http.post(
      Uri.parse('$baseUrl/planned-trips/$id/cancel/'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to cancel planned trip: ${response.statusCode} ${response.body}');
    }
  }
}