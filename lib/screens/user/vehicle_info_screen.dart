import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trackmate_app/controllers/profile_controller.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({Key? key}) : super(key: key);

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final profileController = Get.find<ProfileController>();
  final vehicleNumberController = TextEditingController();
  final vehicleModelController = TextEditingController();
  File? rcImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    vehicleNumberController.text = profileController.vehicleNumber.value;
    vehicleModelController.text = profileController.vehicleModel.value;
  }

  Future<void> pickRCImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        rcImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveVehicle() async {
    if (vehicleNumberController.text.isEmpty || vehicleModelController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    await profileController.updateVehicle(
      number: vehicleNumberController.text,
      model: vehicleModelController.text,
      rcImg: rcImage,
    );
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
          'Vehicle Information',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verification Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      profileController.isVehicleVerified.value
                          ? Icons.verified
                          : Icons.verified_outlined,
                      color: profileController.isVehicleVerified.value
                          ? Colors.green
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      profileController.isVehicleVerified.value
                          ? 'Vehicle Verified'
                          : 'Vehicle Not Verified',
                      style: TextStyle(
                        color: profileController.isVehicleVerified.value
                            ? Colors.green
                            : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Vehicle Number
              _buildTextField(
                controller: vehicleNumberController,
                label: 'Vehicle Number',
                hint: 'e.g., WB12AB3456',
                icon: Icons.confirmation_number,
              ),
              const SizedBox(height: 16),

              // Vehicle Model
              _buildTextField(
                controller: vehicleModelController,
                label: 'Vehicle Model',
                hint: 'e.g., Honda Activa',
                icon: Icons.motorcycle,
              ),
              const SizedBox(height: 24),

              // RC Image Upload
              const Text(
                'Upload RC Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: pickRCImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF7C3AED), width: 2),
                  ),
                  child: rcImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(rcImage!, fit: BoxFit.cover),
                  )
                      : (profileController.rcImage.value.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'http://56.228.42.249${profileController.rcImage.value}',
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate,
                          color: Color(0xFF7C3AED), size: 48),
                      SizedBox(height: 8),
                      Text(
                        'Tap to upload RC image',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  )),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: saveVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Save Vehicle Information',
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
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
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
    vehicleNumberController.dispose();
    vehicleModelController.dispose();
    super.dispose();
  }
}