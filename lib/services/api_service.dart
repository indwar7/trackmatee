import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://56.228.42.249/api';

  // Get auth token from shared preferences
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get headers with auth token
  static Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final token = await getAuthToken();
    final headers = <String, String>{};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  // Profile APIs
  static Future<Map<String, dynamic>> getProfile() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    File? profileImage,
    String? bio,
    String? homeLocation,
    String? workLocation,
  }) async {
    final token = await getAuthToken();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/profile/'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fullName != null) request.fields['full_name'] = fullName;
    if (bio != null) request.fields['bio'] = bio;
    if (homeLocation != null) request.fields['home_location'] = homeLocation;
    if (workLocation != null) request.fields['work_location'] = workLocation;

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', profileImage.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getFullProfile() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/full/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load full profile: ${response.body}');
    }
  }

  // Contact APIs
  static Future<Map<String, dynamic>> addContact({
    required String name,
    required String phoneNumber,
    required String relation,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/profile/contacts/'),
      headers: headers,
      body: json.encode({
        'name': name,
        'phone_number': phoneNumber,
        'relation': relation,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add contact: ${response.body}');
    }
  }

  static Future<List<dynamic>> getContacts() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/contacts/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load contacts: ${response.body}');
    }
  }

  static Future<void> deleteContact(int id) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/profile/contacts/$id/'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete contact: ${response.body}');
    }
  }

  // Aadhaar APIs
  static Future<Map<String, dynamic>> uploadAadhaar({
    required File frontImage,
    required File backImage,
  }) async {
    final token = await getAuthToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/profile/aadhaar/'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      await http.MultipartFile.fromPath('front_image', frontImage.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath('back_image', backImage.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to upload Aadhaar: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getAadhaar() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/aadhaar/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Aadhaar: ${response.body}');
    }
  }

  // Vehicle APIs
  static Future<Map<String, dynamic>> updateVehicle({
    required String vehicleNumber,
    required String vehicleModel,
    File? rcImage,
  }) async {
    final token = await getAuthToken();
    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$baseUrl/profile/vehicle/'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['vehicle_number'] = vehicleNumber;
    request.fields['vehicle_model'] = vehicleModel;

    if (rcImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('rc_image', rcImage.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update vehicle: ${response.body}');
    }
  }
}