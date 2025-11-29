import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackmate_app/controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final profileController = Get.find<ProfileController>();
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final homeController = TextEditingController();
  final workController = TextEditingController();
  File? selectedImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController.text = profileController.fullName.value;
    bioController.text = profileController.bio.value;
    homeController.text = profileController.homeLocation.value;
    workController.text = profileController.workLocation.value;
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveProfile() async {
    await profileController.updateProfile(
      name: nameController.text,
      image: selectedImage,
      bioText: bioController.text,
      home: homeController.text,
      work: workController.text,
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (profileController.isUpdating.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF7C3AED), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 58,
                        backgroundColor: Colors.white,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (profileController.profileImage.value.isNotEmpty
                            ? NetworkImage('http://56.228.42.249${profileController.profileImage.value}')
                            : null) as ImageProvider?,
                        child: selectedImage == null && profileController.profileImage.value.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Color(0xFF2A2A3E))
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7C3AED),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Bio Field
              _buildTextField(
                controller: bioController,
                label: 'Bio',
                icon: Icons.info_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Home Location Field
              _buildTextField(
                controller: homeController,
                label: 'Home Location',
                icon: Icons.home,
              ),
              const SizedBox(height: 16),

              // Work Location Field
              _buildTextField(
                controller: workController,
                label: 'Work Location',
                icon: Icons.work,
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFF7C3AED)),
        filled: true,
        fillColor: const Color(0xFF2A2A3E),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF7C3AED)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    homeController.dispose();
    workController.dispose();
    super.dispose();
  }
}