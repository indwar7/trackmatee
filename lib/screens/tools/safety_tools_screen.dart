import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/screens/user/trusted_contacts_screen.dart';

class SafetyToolsScreen extends StatelessWidget {
  const SafetyToolsScreen({Key? key}) : super(key: key);

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
          'Safety Tools',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSafetyTile(
            title: 'Trusted Contacts',
            subtitle: 'Share your trip status with one or more contacts.',
            onTap: () => Get.to(() => const TrustedContactsScreen()),
          ),
          _buildSafetyTile(
            title: 'Set your emergency contacts',
            subtitle: 'You can make a trusted contact an emergency contact.',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }
}
