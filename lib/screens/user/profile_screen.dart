import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/controllers/profile_controller.dart';
import 'package:trackmate_app/screens/dashboard_screen.dart';
import 'package:trackmate_app/screens/tools/invite_friends_screen.dart';
import 'package:trackmate_app/screens/trips/my_trips_screen.dart';
import 'package:trackmate_app/screens/user/settings_screen.dart';
import 'package:trackmate_app/screens/user/support_screen.dart';
import 'package:trackmate_app/screens/verification/user_verification_screen.dart';
import 'package:trackmate_app/screens/trips/trip_history_screen.dart';
import 'package:trackmate_app/screens/user/edit_profile_screen.dart';
import 'package:trackmate_app/screens/user/vehicle_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF7C3AED), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        backgroundImage: profileController.profileImage.value.isNotEmpty
                            ? NetworkImage('http://56.228.42.249${profileController.profileImage.value}')
                            : null,
                        child: profileController.profileImage.value.isEmpty
                            ? const Icon(Icons.person, size: 40, color: Color(0xFF2A2A3E))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profileController.fullName.value.isEmpty
                                ? 'User'
                                : profileController.fullName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (profileController.bio.value.isNotEmpty)
                            Text(
                              profileController.bio.value,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                profileController.isAadhaarVerified.value
                                    ? Icons.verified
                                    : Icons.verified_outlined,
                                color: profileController.isAadhaarVerified.value
                                    ? Colors.green
                                    : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profileController.isAadhaarVerified.value
                                    ? 'Verified Profile'
                                    : 'Not Verified',
                                style: TextStyle(
                                  color: profileController.isAadhaarVerified.value
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () {
                        Get.to(() => const EditProfileScreen());
                      },
                    ),
                  ],
                ),
              ),

              // Menu Items
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.verified_user,
                      title: 'Verification',
                      onTap: () => Get.to(() => const UserVerificationScreen()),
                    ),
                    const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.directions_car,
                      title: 'Vehicle info',
                      onTap: () => Get.to(() => const VehicleInfoScreen()),
                    ),
                    const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      onTap: () => Get.to(() => const DashboardScreen()),
                    ),
                    const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.card_giftcard,
                      title: 'Invite friends',
                      onTap: () => Get.to(() => const InviteFriendsScreen()),
                    ),
                    const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.airplane_ticket,
                      title: 'My Trips',
                      onTap: () => Get.to(() => const MyTripsScreen()),
                    ),
                    const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Support',
                      onTap: () => Get.to(() => const SupportScreen()),
                    ),
                    const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Setting',
                      onTap: () => Get.to(() => const SettingsScreen()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}