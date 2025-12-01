// 📌 lib/screens/user/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/controllers/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  late TextEditingController addressController;
  late TextEditingController emergencyContactController;

  String? selectedGender;
  String? selectedBloodGroup;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current values
    nameController = TextEditingController(text: profileController.name.value);
    phoneController = TextEditingController(text: profileController.phone.value);
    dobController = TextEditingController(text: profileController.dateOfBirth.value);
    addressController = TextEditingController(text: profileController.address.value);
    emergencyContactController = TextEditingController(text: profileController.emergencyContact.value);

    selectedGender = profileController.gender.value.isNotEmpty ? profileController.gender.value : null;
    selectedBloodGroup = profileController.bloodGroup.value.isNotEmpty ? profileController.bloodGroup.value : null;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // Upload image
        final success = await profileController.updateProfileImage(pickedFile.path);

        if (success) {
          setState(() {}); // Refresh UI
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              surface: Color(0xFF2A2A3E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    // Validate name
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Name cannot be empty",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Validate phone
    if (phoneController.text.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
      if (!phoneRegex.hasMatch(phoneController.text.trim())) {
        Get.snackbar(
          "Validation Error",
          "Please enter a valid phone number",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
    }

    // Update profile
    final success = await profileController.updateProfile(
      newName: nameController.text.trim(),
      newPhone: phoneController.text.trim(),
      newDateOfBirth: dobController.text.trim(),
      newGender: selectedGender,
      newAddress: addressController.text.trim(),
      newEmergencyContact: emergencyContactController.text.trim(),
      newBloodGroup: selectedBloodGroup,
    );

    if (success) {
      // Wait a bit for the success message to show
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.back(); // Go back to profile screen
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
            filled: true,
            fillColor: const Color(0xFF2A2A3E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF8B5CF6),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            dropdownColor: const Color(0xFF2A2A3E),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF8B5CF6),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            hint: Text(
              'Select $label',
              style: const TextStyle(color: Colors.white38),
            ),
            style: const TextStyle(color: Colors.white),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF8B5CF6),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (profileController.profileImage.value.isNotEmpty
                          ? NetworkImage(profileController.profileImage.value)
                          : null) as ImageProvider?,
                      child: _imageFile == null && profileController.profileImage.value.isEmpty
                          ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF8B5CF6),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5CF6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Name
              _buildTextField(
                controller: nameController,
                label: "Full Name",
                icon: Icons.person_outline,
                hint: "Enter your full name",
              ),

              // Phone
              _buildTextField(
                controller: phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                hint: "Enter your phone number",
                keyboardType: TextInputType.phone,
              ),

              // Date of Birth
              _buildTextField(
                controller: dobController,
                label: "Date of Birth",
                icon: Icons.calendar_today_outlined,
                hint: "Select your date of birth",
                readOnly: true,
                onTap: _selectDate,
              ),

              // Gender
              _buildDropdown(
                label: "Gender",
                icon: Icons.person_outline,
                value: selectedGender,
                items: genderOptions,
                onChanged: (value) {
                  setState(() => selectedGender = value);
                },
              ),

              // Blood Group
              _buildDropdown(
                label: "Blood Group",
                icon: Icons.bloodtype_outlined,
                value: selectedBloodGroup,
                items: bloodGroups,
                onChanged: (value) {
                  setState(() => selectedBloodGroup = value);
                },
              ),

              // Address
              _buildTextField(
                controller: addressController,
                label: "Address",
                icon: Icons.location_on_outlined,
                hint: "Enter your address",
                maxLines: 3,
              ),

              // Emergency Contact
              _buildTextField(
                controller: emergencyContactController,
                label: "Emergency Contact",
                icon: Icons.emergency_outlined,
                hint: "Emergency contact number",
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: profileController.isLoading.value ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    disabledBackgroundColor: const Color(0xFF8B5CF6).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: profileController.isLoading.value
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }
}