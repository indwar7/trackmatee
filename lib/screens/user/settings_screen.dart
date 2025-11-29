import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/controllers/language_controller.dart';
import 'package:trackmate_app/controllers/profile_controller.dart';
import 'package:trackmate_app/screens/places/add_home_screen.dart';
import 'package:trackmate_app/screens/places/add_work_screen.dart';
import 'package:trackmate_app/screens/tools/safety_tools_screen.dart';
import 'package:trackmate_app/screens/user/vehicle_info_screen.dart';
import 'package:trackmate_app/screens/verification/user_verification_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    final LanguageController languageController = Get.find<LanguageController>();

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
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Language'),
          Obx(() => _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: languageController.getLanguageByCode(languageController.getCurrentLanguage())?.name ?? 'English',
            onTap: () => _showLanguageDialog(context, languageController),
          )),

          _buildSectionHeader('Shortcuts'),
          Obx(() => _buildSettingsTile(
            icon: Icons.home,
            title: 'Home',
            subtitle: profileController.homeLocation.value.isEmpty
                ? 'Add Shortcut'
                : profileController.homeLocation.value,
            onTap: () => Get.to(() => const AddHomeScreen()),
          )),
          Obx(() => _buildSettingsTile(
            icon: Icons.work,
            title: 'Work',
            subtitle: profileController.workLocation.value.isEmpty
                ? 'Add Shortcut'
                : profileController.workLocation.value,
            onTap: () => Get.to(() => const AddWorkScreen()),
          )),

          _buildSectionHeader('Document'),
          _buildSettingsTile(
            icon: Icons.verified_user,
            title: 'Verification',
            onTap: () => Get.to(() => const UserVerificationScreen()),
          ),
          Obx(() => _buildSettingsTile(
            icon: Icons.directions_car,
            title: 'Saved vehicle data',
            subtitle: profileController.vehicleNumber.value.isNotEmpty
                ? '${profileController.vehicleNumber.value} - ${profileController.vehicleModel.value}'
                : 'No vehicle added',
            onTap: () => Get.to(() => const VehicleInfoScreen()),
          )),

          _buildSectionHeader('Safety'),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Safety tools',
            onTap: () => Get.to(() => const SafetyToolsScreen()),
          ),
          _buildSettingsTile(
            icon: Icons.gavel,
            title: 'Legal',
            onTap: () {
              // TODO: Implement legal screen
            },
          ),

          const SizedBox(height: 32),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2A2A3E),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        // TODO: Implement logout
                        Get.offAllNamed('/login');
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF2A2A3E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...controller.supportedLanguages.map((lang) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          controller.changeLanguage(lang.code);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          lang.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      if (lang != controller.supportedLanguages.last)
                        const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white70)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}