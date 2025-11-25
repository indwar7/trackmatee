import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/screens/user/profile_screen.dart';

class IdStatusScreen extends StatelessWidget {
  const IdStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offAll(() => const ProfileScreen()), // Go back to profile screen
        ),
        title: const Text(
          'Upload Documents',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Front side of the ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
             const SizedBox(height: 8),
            const Text(
              'Make sure the lighting is good and letters are clearly visible.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/aadhar_1.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 32),
            const Text(
              'Back side of the ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
             const SizedBox(height: 8),
            const Text(
              'Make sure the lighting is good and letters are clearly visible.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/aadhar_2.png', fit: BoxFit.contain),
            ),
             const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle document submission
                Get.snackbar(
                  'Success',
                  'Documents uploaded successfully!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Capture Photo',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
