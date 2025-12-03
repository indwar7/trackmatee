// 📌 lib/controllers/profile_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:trackmate_app/services/auth_service.dart';

class ProfileController extends GetxController {
  final _storage = GetStorage();

  // Observable variables
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var profileImage = ''.obs;
  var isLoading = false.obs;
  var isUpdating = false.obs;

  // Additional profile fields
  var dateOfBirth = ''.obs;
  var gender = ''.obs;
  var address = ''.obs;
  var emergencyContact = ''.obs;
  var bloodGroup = ''.obs;
  var bio = ''.obs;
  var fullName = ''.obs;
  var homeLocation = ''.obs;
  var workLocation = ''.obs;

  // Vehicle info
  var vehicleNumber = ''.obs;
  var vehicleModel = ''.obs;
  var isVehicleVerified = false.obs;

  // Aadhaar verification
  var aadhaarFrontImage = ''.obs;
  var aadhaarBackImage = ''.obs;
  var isAadhaarVerified = false.obs;

  // Trusted contacts
  final trustedContacts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileFromStorage();
    fetchProfile();
  }

  // Load profile from local storage
  void loadProfileFromStorage() {
    try {
      final authService = Get.find<AuthService>();
      name.value = _storage.read('username') ?? authService.username;
      fullName.value = _storage.read('fullName') ?? name.value;
      email.value = _storage.read('email') ?? authService.email;
      phone.value = _storage.read('phone') ?? '';
      profileImage.value = _storage.read('profileImage') ?? '';
      dateOfBirth.value = _storage.read('dateOfBirth') ?? '';
      gender.value = _storage.read('gender') ?? '';
      address.value = _storage.read('address') ?? '';
      emergencyContact.value = _storage.read('emergencyContact') ?? '';
      bloodGroup.value = _storage.read('bloodGroup') ?? '';
      bio.value = _storage.read('bio') ?? '';
      homeLocation.value = _storage.read('homeLocation') ?? '';
      workLocation.value = _storage.read('workLocation') ?? '';
      vehicleNumber.value = _storage.read('vehicleNumber') ?? '';
      vehicleModel.value = _storage.read('vehicleModel') ?? '';
      isVehicleVerified.value = _storage.read('isVehicleVerified') ?? false;
      aadhaarFrontImage.value = _storage.read('aadhaarFrontImage') ?? '';
      aadhaarBackImage.value = _storage.read('aadhaarBackImage') ?? '';
      isAadhaarVerified.value = _storage.read('isAadhaarVerified') ?? false;

      // Load trusted contacts
      final storedContacts = _storage.read<List>('trusted_contacts');
      if (storedContacts != null) {
        trustedContacts.value = storedContacts.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  // Fetch profile from API
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      final authService = Get.find<AuthService>();
      final token = authService.token;

      if (token.isEmpty) {
        print("No auth token found");
        loadProfileFromStorage();
        return;
      }

      final response = await http.get(
        Uri.parse("http://56.228.42.249/api/user/profile/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        name.value = data['name'] ?? data['username'] ?? '';
        fullName.value = data['full_name'] ?? data['name'] ?? '';
        email.value = data['email'] ?? '';
        phone.value = data['phone'] ?? '';
        profileImage.value = data['profile_image'] ?? '';
        dateOfBirth.value = data['date_of_birth'] ?? '';
        gender.value = data['gender'] ?? '';
        address.value = data['address'] ?? '';
        emergencyContact.value = data['emergency_contact'] ?? '';
        bloodGroup.value = data['blood_group'] ?? '';
        bio.value = data['bio'] ?? '';
        homeLocation.value = data['home_location'] ?? '';
        workLocation.value = data['work_location'] ?? '';
        vehicleNumber.value = data['vehicle_number'] ?? '';
        vehicleModel.value = data['vehicle_model'] ?? '';

        saveProfileToStorage();
      }
    } catch (e) {
      print("Error fetching profile: $e");
      loadProfileFromStorage();
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? newName,
    String? newFullName,
    String? newPhone,
    String? newDateOfBirth,
    String? newGender,
    String? newAddress,
    String? newEmergencyContact,
    String? newBloodGroup,
    String? newBio,
    String? newHomeLocation,
    String? newWorkLocation,
  }) async {
    try {
      isUpdating.value = true;

      if (newName != null) name.value = newName;
      if (newFullName != null) fullName.value = newFullName;
      if (newPhone != null) phone.value = newPhone;
      if (newDateOfBirth != null) dateOfBirth.value = newDateOfBirth;
      if (newGender != null) gender.value = newGender;
      if (newAddress != null) address.value = newAddress;
      if (newEmergencyContact != null) emergencyContact.value = newEmergencyContact;
      if (newBloodGroup != null) bloodGroup.value = newBloodGroup;
      if (newBio != null) bio.value = newBio;
      if (newHomeLocation != null) homeLocation.value = newHomeLocation;
      if (newWorkLocation != null) workLocation.value = newWorkLocation;

      saveProfileToStorage();

      Get.snackbar(
        "Success",
        "Profile updated successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return true;
    } catch (e) {
      print("Error updating profile: $e");

      Get.snackbar(
        "Error",
        "Failed to update profile",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Save profile to local storage
  void saveProfileToStorage() {
    _storage.write('username', name.value);
    _storage.write('fullName', fullName.value);
    _storage.write('email', email.value);
    _storage.write('phone', phone.value);
    _storage.write('profileImage', profileImage.value);
    _storage.write('dateOfBirth', dateOfBirth.value);
    _storage.write('gender', gender.value);
    _storage.write('address', address.value);
    _storage.write('emergencyContact', emergencyContact.value);
    _storage.write('bloodGroup', bloodGroup.value);
    _storage.write('bio', bio.value);
    _storage.write('homeLocation', homeLocation.value);
    _storage.write('workLocation', workLocation.value);
    _storage.write('vehicleNumber', vehicleNumber.value);
    _storage.write('vehicleModel', vehicleModel.value);
    _storage.write('isVehicleVerified', isVehicleVerified.value);
    _storage.write('aadhaarFrontImage', aadhaarFrontImage.value);
    _storage.write('aadhaarBackImage', aadhaarBackImage.value);
    _storage.write('isAadhaarVerified', isAadhaarVerified.value);
    _storage.write('trusted_contacts', trustedContacts.toList());
  }

  // Update profile image
  Future<bool> updateProfileImage(String imagePath) async {
    try {
      isLoading.value = true;

      // Simulate image upload
      await Future.delayed(const Duration(seconds: 1));

      profileImage.value = imagePath;
      saveProfileToStorage();

      Get.snackbar(
        "Success",
        "Profile picture updated!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      print("Error updating profile image: $e");

      Get.snackbar(
        "Error",
        "Failed to upload image",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Upload Aadhaar
  Future<bool> uploadAadhaar({
    required String frontImage,
    required String backImage,
  }) async {
    try {
      isUpdating.value = true;

      // Simulate upload
      await Future.delayed(const Duration(seconds: 2));

      aadhaarFrontImage.value = frontImage;
      aadhaarBackImage.value = backImage;
      isAadhaarVerified.value = true;

      saveProfileToStorage();

      Get.snackbar(
        "Success",
        "Aadhaar uploaded successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      print("Error uploading Aadhaar: $e");

      Get.snackbar(
        "Error",
        "Failed to upload Aadhaar",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Trusted Contacts Methods
  void addTrustedContact(String name, String phone) {
    final contact = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'phone': phone,
    };
    trustedContacts.add(contact);
    saveProfileToStorage();
  }

  void removeTrustedContact(int index) {
    if (index >= 0 && index < trustedContacts.length) {
      trustedContacts.removeAt(index);
      saveProfileToStorage();
    }
  }

  // Clear profile data (for logout)
  void clearProfile() {
    name.value = '';
    fullName.value = '';
    email.value = '';
    phone.value = '';
    profileImage.value = '';
    dateOfBirth.value = '';
    gender.value = '';
    address.value = '';
    emergencyContact.value = '';
    bloodGroup.value = '';
    bio.value = '';
    homeLocation.value = '';
    workLocation.value = '';
    vehicleNumber.value = '';
    vehicleModel.value = '';
    isVehicleVerified.value = false;
    aadhaarFrontImage.value = '';
    aadhaarBackImage.value = '';
    isAadhaarVerified.value = false;
    trustedContacts.clear();

    _storage.erase();
  }
}