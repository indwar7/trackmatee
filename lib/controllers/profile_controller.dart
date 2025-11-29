import 'dart:io';
import 'package:get/get.dart';
import 'package:trackmate_app/services/api_service.dart';

class ProfileController extends GetxController {
  // Profile data
  var fullName = ''.obs;
  var profileImage = ''.obs;
  var bio = ''.obs;
  var homeLocation = ''.obs;
  var workLocation = ''.obs;
  var email = ''.obs;

  // Trusted contacts
  var trustedContacts = <TrustedContact>[].obs;

  // Aadhaar verification
  var aadhaarFrontImage = ''.obs;
  var aadhaarBackImage = ''.obs;
  var isAadhaarVerified = false.obs;

  // Vehicle
  var vehicleNumber = ''.obs;
  var vehicleModel = ''.obs;
  var rcImage = ''.obs;
  var isVehicleVerified = false.obs;

  // Loading states
  var isLoading = false.obs;
  var isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFullProfile();
  }

  // Load full profile
  Future<void> loadFullProfile() async {
    try {
      isLoading.value = true;
      final data = await ApiService.getFullProfile();

      fullName.value = data['full_name'] ?? '';
      profileImage.value = data['profile_image'] ?? '';
      bio.value = data['bio'] ?? '';
      homeLocation.value = data['home_location'] ?? '';
      workLocation.value = data['work_location'] ?? '';

      // Load trusted contacts
      if (data['trusted_contacts'] != null) {
        trustedContacts.value = (data['trusted_contacts'] as List)
            .map((c) => TrustedContact.fromJson(c))
            .toList();
      }

      // Load Aadhaar info
      if (data['aadhaar_verification'] != null) {
        final aadhaar = data['aadhaar_verification'];
        aadhaarFrontImage.value = aadhaar['front_image'] ?? '';
        aadhaarBackImage.value = aadhaar['back_image'] ?? '';
        isAadhaarVerified.value = aadhaar['is_verified'] ?? false;
      }

      // Load vehicle info
      if (data['vehicles'] != null && (data['vehicles'] as List).isNotEmpty) {
        final vehicle = (data['vehicles'] as List).first;
        vehicleNumber.value = vehicle['vehicle_number'] ?? '';
        vehicleModel.value = vehicle['vehicle_model'] ?? '';
        rcImage.value = vehicle['rc_image'] ?? '';
        isVehicleVerified.value = vehicle['is_verified'] ?? false;
      }

    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    File? image,
    String? bioText,
    String? home,
    String? work,
  }) async {
    try {
      isUpdating.value = true;

      final data = await ApiService.updateProfile(
        fullName: name,
        profileImage: image,
        bio: bioText,
        homeLocation: home,
        workLocation: work,
      );

      fullName.value = data['full_name'] ?? '';
      profileImage.value = data['profile_image'] ?? '';
      bio.value = data['bio'] ?? '';
      homeLocation.value = data['home_location'] ?? '';
      workLocation.value = data['work_location'] ?? '';

      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdating.value = false;
    }
  }

  // Add trusted contact
  Future<void> addTrustedContact({
    required String name,
    required String phoneNumber,
    required String relation,
  }) async {
    try {
      final data = await ApiService.addContact(
        name: name,
        phoneNumber: phoneNumber,
        relation: relation,
      );

      trustedContacts.add(TrustedContact.fromJson(data));

      Get.snackbar('Success', 'Contact added successfully',
          snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      Get.snackbar('Error', 'Failed to add contact: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Remove trusted contact
  Future<void> removeTrustedContact(int id) async {
    try {
      await ApiService.deleteContact(id);
      trustedContacts.removeWhere((c) => c.id == id);

      Get.snackbar('Success', 'Contact removed successfully',
          snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      Get.snackbar('Error', 'Failed to remove contact: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Upload Aadhaar
  Future<void> uploadAadhaar({
    required File frontImage,
    required File backImage,
  }) async {
    try {
      isUpdating.value = true;

      final data = await ApiService.uploadAadhaar(
        frontImage: frontImage,
        backImage: backImage,
      );

      aadhaarFrontImage.value = data['front_image'] ?? '';
      aadhaarBackImage.value = data['back_image'] ?? '';
      isAadhaarVerified.value = data['is_verified'] ?? false;

      Get.snackbar('Success', 'Aadhaar uploaded successfully',
          snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      Get.snackbar('Error', 'Failed to upload Aadhaar: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdating.value = false;
    }
  }

  // Update vehicle
  Future<void> updateVehicle({
    required String number,
    required String model,
    File? rcImg,
  }) async {
    try {
      isUpdating.value = true;

      final data = await ApiService.updateVehicle(
        vehicleNumber: number,
        vehicleModel: model,
        rcImage: rcImg,
      );

      vehicleNumber.value = data['vehicle_number'] ?? '';
      vehicleModel.value = data['vehicle_model'] ?? '';
      rcImage.value = data['rc_image'] ?? '';
      isVehicleVerified.value = data['is_verified'] ?? false;

      Get.snackbar('Success', 'Vehicle updated successfully',
          snackPosition: SnackPosition.BOTTOM);

    } catch (e) {
      Get.snackbar('Error', 'Failed to update vehicle: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdating.value = false;
    }
  }
}

// Model classes
class TrustedContact {
  final int id;
  final String name;
  final String phoneNumber;
  final String relation;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relation,
  });

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      relation: json['relation'],
    );
  }
}