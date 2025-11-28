import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/screens/id_capture_tips_screen.dart';

class UserVerificationScreen extends StatelessWidget {
  const UserVerificationScreen({Key? key}) : super(key: key);

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
          'User Verification',
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
              'Verify Your Driving License to Begin Offering Trips',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Photo of your Government ID is required to validate your identity.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.white),
              title: const Text('Government ID', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Not uploaded', style: TextStyle(color: Colors.red)),
              onTap: () => Get.to(() => const IdCaptureTipsScreen()),
            ),
          ],
        ),
      ),
    );
  }
}