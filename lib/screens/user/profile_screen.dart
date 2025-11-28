import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/screens/dashboard_screen.dart';
import 'package:trackmate_app/screens/tools/invite_friends_screen.dart';
import 'package:trackmate_app/screens/trips/my_trips_screen.dart';
import 'package:trackmate_app/screens/user/settings_screen.dart';
import 'package:trackmate_app/screens/user/support_screen.dart';
import 'package:trackmate_app/screens/verification/user_verification_screen.dart';
import 'package:trackmate_app/screens/trips/trip_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Color(0xFF2A2A3E)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanvee Saxena',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'tanveesaxena@example.com',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Verified Profile',
                              style: TextStyle(
                                color: Colors.green,
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
                      // TODO: Implement edit profile
                    },
                  ),
                ],
              ),
            ),

            // Wallet & Rewards
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet & Rewards',
                    onTap: () {
                      // TODO: Implement wallet & rewards
                    },
                  ),
                  const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Refer & Earn',
                    onTap: () {
                      Get.to(() => const InviteFriendsScreen());
                    },
                  ),
                ],
              ),
            ),

            // My Trips & History
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.airplane_ticket_outlined,
                    title: 'My Trips',
                    onTap: () {
                      Get.to(() => const MyTripsScreen());
                    },
                  ),
                  const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.history_outlined,
                    title: 'Trip History',
                    onTap: () {
                      Get.to(() => const TripHistoryScreen());
                    },
                  ),
                ],
              ),
            ),

            // Support & Legal
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Get.to(() => const SupportScreen());
                    },
                  ),
                  const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.security_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      // TODO: Implement privacy policy
                    },
                  ),
                  const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {
                      // TODO: Implement terms & conditions
                    },
                  ),
                ],
              ),
            ),

            // Settings & Logout
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Get.to(() => const SettingsScreen());
                    },
                  ),
                  const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.verified_user,
                    title: 'Verification',
                    onTap: () => Get.to(() => const UserVerificationScreen()),
                  ),
                  const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () => Get.to(() => const DashboardScreen()),
                  ),
                  const Divider(height: 1, color: Colors.white24, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () {
                      Get.offAllNamed('/login');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
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
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A4E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
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