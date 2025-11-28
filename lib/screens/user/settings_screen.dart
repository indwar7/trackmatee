import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/controllers/language_controller.dart';
import 'package:trackmate_app/controllers/saved_places_controller.dart';
import 'package:trackmate_app/screens/places/add_home_screen.dart';
import 'package:trackmate_app/screens/places/add_work_screen.dart';
import 'package:trackmate_app/screens/tools/safety_tools_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savedPlacesController = Get.find<SavedPlacesController>();
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
            subtitle: savedPlacesController.homeAddress.value ?? 'Add Shortcut',
            onTap: () => Get.to(() => const AddHomeScreen()),
          )),
          Obx(() => _buildSettingsTile(
            icon: Icons.work,
            title: 'Work',
            subtitle: savedPlacesController.workAddress.value ?? 'Add Shortcut',
            onTap: () => Get.to(() => const AddWorkScreen()),
          )),
          _buildSectionHeader('Document'),
          _buildSettingsTile(
            icon: Icons.verified_user,
            title: 'Verification',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.history,
            title: 'Status',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.save,
            title: 'Saved vehicle data',
            onTap: () {},
          ),
          _buildSectionHeader('Safety'),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Safety tools',
            onTap: () => Get.to(() => const SafetyToolsScreen()),
          ),
          _buildSettingsTile(
            icon: Icons.gavel,
            title: 'Legal',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () {},
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
                        const Divider(
                          color: Colors.white24,
                          height: 16,
                          thickness: 1,
                        ),
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
      onTap: onTap,
    );
  }
}