import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://56.228.42.249/api";

  String? accessToken;
  String? refreshToken;

  /// =====================================================
  /// TOKEN MANAGEMENT
  /// =====================================================
  Map<String, String> get authHeaders => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $accessToken",
  };

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("access_token");
    refreshToken = prefs.getString("refresh_token");
    debugPrint('🔑 Tokens loaded - Access: ${accessToken?.substring(0, 20)}...');
  }

  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", access);
    await prefs.setString("refresh_token", refresh);
    accessToken = access;
    refreshToken = refresh;
    debugPrint('💾 Tokens saved');
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
    await prefs.remove("refresh_token");
    accessToken = null;
    refreshToken = null;
    debugPrint('🗑️ Tokens cleared');
  }

  /// =====================================================
  /// HEADERS
  /// =====================================================

  Map<String, String> get headers {
    return {
      "Content-Type": "application/json",
      if (accessToken != null) "Authorization": "Bearer $accessToken",
    };
  }

  /// =====================================================
  /// AUTH
  /// =====================================================

  Future<Map<String, dynamic>> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "username": username,
        "password": password,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/verify/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "code": code,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data["access"], data["refresh"]);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    try {
      debugPrint('🔐 Starting logout...');

      if (refreshToken == null || refreshToken!.isEmpty) {
        debugPrint('⚠️ No refresh token found, clearing local tokens only');
        await clearTokens();
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/auth/logout/"),
        headers: {
          "Content-Type": "application/json",
          if (accessToken != null) "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({
          "refresh": refreshToken,
        }),
      );

      debugPrint('📡 Logout Status Code: ${response.statusCode}');

      // Clear tokens regardless of response
      await clearTokens();

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Logout successful');
      } else if (response.statusCode == 401) {
        debugPrint('⚠️ Token already invalid (401), logout successful');
      } else {
        debugPrint('⚠️ Logout returned ${response.statusCode}, but tokens cleared locally');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Logout error: $e');
      debugPrint('Stack trace: $stackTrace');

      // CRITICAL: Always clear tokens even if API call fails
      await clearTokens();
      debugPrint('✅ Tokens cleared locally despite error');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/forgot-password/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/reset-password/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "code": code,
        "new_password": newPassword,
      }),
    );
    return jsonDecode(response.body);
  }

  /// =====================================================
  /// PROFILE
  /// =====================================================

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? bio,
    String? homeLocation,
    String? workLocation,
    File? profileImage,
  }) async {
    final request = http.MultipartRequest(
      "PUT",
      Uri.parse("$baseUrl/profile/"),
    );

    request.headers["Authorization"] = "Bearer $accessToken";

    if (fullName != null) request.fields["full_name"] = fullName;
    if (bio != null) request.fields["bio"] = bio;
    if (homeLocation != null) request.fields["home_location"] = homeLocation;
    if (workLocation != null) request.fields["work_location"] = workLocation;

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath("profile_image", profileImage.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getFullProfile() async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/full/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  /// =====================================================
  /// CONTACTS
  /// =====================================================

  Future<Map<String, dynamic>> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/profile/contacts/"),
      headers: headers,
      body: jsonEncode({
        "name": name,
        "phone_number": phone,
        "relation": relation,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getContacts() async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/contacts/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  Future<void> deleteContact(int id) async {
    await http.delete(
      Uri.parse("$baseUrl/profile/contacts/$id/"),
      headers: headers,
    );
  }

  /// =====================================================
  /// AADHAAR
  /// =====================================================

  Future<Map<String, dynamic>> uploadAadhaar({
    required File front,
    required File back,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/profile/aadhaar/"),
    );

    request.headers["Authorization"] = "Bearer $accessToken";
    request.files.add(
      await http.MultipartFile.fromPath("front_image", front.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath("back_image", back.path),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getAadhaar() async {
    final response = await http.get(
      Uri.parse("$baseUrl/profile/aadhaar/"),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  /// =====================================================
  /// VEHICLE
  /// =====================================================

  Future<Map<String, dynamic>> updateVehicle({
    required String number,
    required String model,
    File? rcImage,
  }) async {
    final request = http.MultipartRequest(
      "PATCH",
      Uri.parse("$baseUrl/profile/vehicle/"),
    );

    request.headers["Authorization"] = "Bearer $accessToken";
    request.fields["vehicle_number"] = number;
    request.fields["vehicle_model"] = model;

    if (rcImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath("rc_image", rcImage.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return jsonDecode(response.body);
  }

  /// =====================================================
  /// LIVE TRIP TRACKING
  /// =====================================================

  Future<Map<String, dynamic>> startTrip({
    required double startLat,
    required double startLng,
    String? locationName,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/trips/start/"),
      headers: headers,
      body: jsonEncode({
        "start_latitude": startLat,
        "start_longitude": startLng,
        if (locationName != null) "start_location_name": locationName,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start trip: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> addTrackingPoint({
    required int tripId,
    required double lat,
    required double lng,
    required double accuracy,
    double? speed,
    String? timestamp,
  }) async {
    final body = {
      "latitude": lat,
      "longitude": lng,
      "accuracy": accuracy,
      if (speed != null) "speed": speed,
      if (timestamp != null) "timestamp": timestamp,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/trips/$tripId/add-tracking-point/"),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add tracking point: ${response.statusCode}');
    }
  }

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
      "end_latitude": endLat,
      "end_longitude": endLng,
      if (endLocationName != null) "end_location_name": endLocationName,
      if (modeOfTravel != null) "mode_of_travel": modeOfTravel,
      if (tripPurpose != null) "trip_purpose": tripPurpose,
      if (companions != null) "number_of_companions": companions,
      if (fuelExpense != null) "fuel_expense": fuelExpense,
      if (parkingCost != null) "parking_cost": parkingCost,
      if (tollCost != null) "toll_cost": tollCost,
      if (ticketCost != null) "ticket_cost": ticketCost,
      if (fuelType != null) "fuel_type": fuelType,
      if (co2Emitted != null) "co2_emitted": co2Emitted,
      if (totalCost != null) "total_cost": totalCost,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/trips/$tripId/end/"),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to end trip: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> getOngoingTrip() async {
    final response = await http.get(
      Uri.parse("$baseUrl/trips/ongoing/"),
      headers: headers,
    );

    if (response.statusCode == 404 || response.statusCode == 401 || response.statusCode == 403) {
      return null;
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded == null) return null;

      if (decoded is Map<String, dynamic>) {
        // Check if it's the trip directly
        if (decoded.containsKey('id') && _looksActive(decoded)) {
          return decoded;
        }
        // Check if trip is nested
        if (decoded.containsKey('trip') && decoded['trip'] is Map<String, dynamic>) {
          final trip = decoded['trip'] as Map<String, dynamic>;
          if (_looksActive(trip)) return trip;
        }
      }
      return null;
    }

    throw Exception('Failed to get ongoing trip: ${response.statusCode}');
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

  /// =====================================================
  /// TRIP HISTORY & DETAILS
  /// =====================================================

  Future<Map<String, dynamic>> getTripHistory({
    String? dateFrom,
    String? dateTo,
    String? mode,
    String? purpose,
    String? ordering,
  }) async {
    try {
      final query = <String, String>{};
      if (dateFrom != null) query["date_from"] = dateFrom;
      if (dateTo != null) query["date_to"] = dateTo;
      if (mode != null) query["mode"] = mode;
      if (purpose != null) query["purpose"] = purpose;
      if (ordering != null) query["ordering"] = ordering;

      final uri = Uri.parse("$baseUrl/trips/history/").replace(
        queryParameters: query.isEmpty ? null : query,
      );

      debugPrint("🌐 Request URL: $uri");
      debugPrint("🔑 Has Token: ${accessToken != null}");

      final response = await http.get(uri, headers: headers);

      debugPrint("📡 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle if response is directly a list
        if (data is List) {
          return {"count": data.length, "trips": data};
        }

        // Handle if response is a map
        if (data is Map<String, dynamic>) {
          return data;
        }

        return {"count": 0, "trips": []};
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized. Please login again.");
      } else if (response.statusCode == 404) {
        return {"count": 0, "trips": []};
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ API Error in getTripHistory: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTripDetails(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/trips/$id/"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get trip details: ${response.statusCode}');
    }
  }

  /// =====================================================
  /// LIVE TRIP TRACKING - END TRIP (FIXED FOR 401 ERROR)
  /// =====================================================

  Future<Map<String, dynamic>> EndTrip({
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
    try {
      // 🔑 CRITICAL FIX: Ensure token is loaded
      await loadTokens();

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔐 API SERVICE - END TRIP');
      debugPrint('Token Present: ${accessToken != null}');
      debugPrint('Token Length: ${accessToken?.length ?? 0}');
      debugPrint('Token Preview: ${accessToken?.substring(0, 30)}...');
      debugPrint('Trip ID: $tripId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (accessToken == null || accessToken!.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final body = {
        "end_latitude": endLat,
        "end_longitude": endLng,
        if (endLocationName != null) "end_location_name": endLocationName,
        if (modeOfTravel != null) "mode_of_travel": modeOfTravel,
        if (tripPurpose != null) "trip_purpose": tripPurpose,
        if (companions != null) "number_of_companions": companions,
        if (fuelExpense != null) "fuel_expense": fuelExpense,
        if (parkingCost != null) "parking_cost": parkingCost,
        if (tollCost != null) "toll_cost": tollCost,
        if (ticketCost != null) "ticket_cost": ticketCost,
        if (fuelType != null) "fuel_type": fuelType,
        if (co2Emitted != null) "co2_emitted": co2Emitted,
        if (totalCost != null) "total_cost": totalCost,
      };

      debugPrint('📤 Request Body: ${jsonEncode(body)}');
      debugPrint('📤 Headers: $headers');

      final response = await http.post(
        Uri.parse("$baseUrl/trips/$tripId/end/"),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Trip ended successfully');
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        debugPrint('❌ Authentication failed (401)');
        throw Exception('Unauthorized: Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        debugPrint('❌ Trip not found (404)');
        throw Exception('Trip not found. It may have already been ended.');
      } else {
        debugPrint('❌ Server error: ${response.statusCode}');
        throw Exception('Failed to end trip: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ EXCEPTION IN endTrip()');
      debugPrint('Error: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  /// =====================================================
  /// MANUAL TRIPS
  /// =====================================================

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
      "start_latitude": startLat,
      "start_longitude": startLng,
      "end_latitude": endLat,
      "end_longitude": endLng,
      if (startLocation != null) "start_location": startLocation,
      if (endLocation != null) "end_location": endLocation,
      if (tripDate != null) "trip_date": tripDate,
      if (modeOfTravel != null) "mode_of_travel": modeOfTravel,
      if (tripPurpose != null) "trip_purpose": tripPurpose,
      if (companions != null) "number_of_companions": companions,
      if (fuelExpense != null) "fuel_expense": fuelExpense,
      if (parkingCost != null) "parking_cost": parkingCost,
      if (tollCost != null) "toll_cost": tollCost,
      if (ticketCost != null) "ticket_cost": ticketCost,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/trips/create-manual/"),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create manual trip: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> previewRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String? startName,
    String? endName,
    String mode = "car",
  }) async {
    final body = {
      "start_latitude": startLat,
      "start_longitude": startLng,
      "end_latitude": endLat,
      "end_longitude": endLng,
      "mode_of_travel": mode,
      if (startName != null) "start_location_name": startName,
      if (endName != null) "end_location_name": endName,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/trips/preview-route/"),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to preview route: ${response.statusCode}');
    }
  }

  /// =====================================================
  /// PLANNED TRIPS
  /// =====================================================

  Future<List<dynamic>> getPlannedTrips({
    String? status,
    String? ordering,
  }) async {
    final query = <String, String>{};
    if (status != null) query["status"] = status;
    if (ordering != null) query["ordering"] = ordering;

    final uri = Uri.parse("$baseUrl/planned-trips/").replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      return [];
    } else {
      throw Exception('Failed to get planned trips: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createPlannedTrip(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/planned-trips/"),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create planned trip: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getPlannedTripDetails(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/planned-trips/$id/"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get planned trip: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updatePlannedTrip(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/planned-trips/$id/"),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update planned trip: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> patchPlannedTrip(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/planned-trips/$id/"),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to patch planned trip: ${response.statusCode}');
    }
  }

  Future<void> deletePlannedTrip(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/planned-trips/$id/"),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete planned trip: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getUpcomingTrips() async {
    final response = await http.get(
      Uri.parse("$baseUrl/planned-trips/upcoming/"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      return [];
    } else {
      throw Exception('Failed to get upcoming trips: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> startPlannedTrip(int id, {
    double? lat,
    double? lng,
    String? name,
  }) async {
    final body = {
      if (lat != null) "start_latitude": lat,
      if (lng != null) "start_longitude": lng,
      if (name != null) "start_location_name": name,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/planned-trips/$id/start_trip/"),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start planned trip: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> cancelPlannedTrip(int id, {String? reason}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/planned-trips/$id/cancel/"),
      headers: headers,
      body: jsonEncode({
        if (reason != null) "reason": reason,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to cancel planned trip: ${response.statusCode}');
    }
  }

  /// =====================================================
  /// ANALYTICS / STATS
  /// =====================================================

  Future<Map<String, dynamic>> getDailyScore({String? date}) async {
    final uri = Uri.parse("$baseUrl/trips/stats/daily-score/")
        .replace(queryParameters: date != null ? {"date": date} : null);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get daily score: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getCalendarStats({
    int? month,
    int? year,
  }) async {
    final query = <String, String>{};
    if (month != null) query["month"] = "$month";
    if (year != null) query["year"] = "$year";

    final uri = Uri.parse("$baseUrl/trips/stats/calendar-stats/")
        .replace(queryParameters: query.isEmpty ? null : query);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get calendar stats: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getMonthlyChartData({
    int? month,
    int? year,
  }) async {
    final query = <String, String>{};
    if (month != null) query["month"] = "$month";
    if (year != null) query["year"] = "$year";

    final uri = Uri.parse("$baseUrl/trips/stats/monthly-chart/")
        .replace(queryParameters: query.isEmpty ? null : query);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get monthly chart: ${response.statusCode}');
    }
  }
}

