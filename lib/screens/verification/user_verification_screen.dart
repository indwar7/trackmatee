import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ✅ CORRECT IMPORT – matches file: lib/screens/aadhaar_verification_screen.dart
import 'package:trackmate_app/screens/aadhaar_verification_screen.dart';

class UserVerificationScreen extends StatelessWidget {
  const UserVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text(
          "User Verification",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _tile(
              "Aadhaar Verification",
              Icons.badge,
                  () {
                // ✅ Use the real widget class from aadhaar_verification_screen.dart
                Get.to(() => const AadhaarVerificationScreen());
              },
            ),

            const SizedBox(height: 20),

            _tile(
              "ID Capture",
              Icons.camera_alt,
                  () {
                Get.toNamed("/capture-id");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      tileColor: const Color(0xFF222244),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white38,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
