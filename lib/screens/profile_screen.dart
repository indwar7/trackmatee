import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackmate_app/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // 🔥 AuthService instance to get stored username + email
    final auth = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ---------------- PROFILE IMAGE ----------------
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF8B5CF6),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // 🔥 DYNAMIC USERNAME (no UI changed)
            Text(
              auth.username.isNotEmpty ? auth.username.capitalize! : "User",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 DYNAMIC EMAIL
            Text(
              auth.email.isNotEmpty ? auth.email : "no-email@user.com",
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            _buildProfileMenuItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _buildProfileMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),

            // 🔥 Logout through AuthService (session + token clear)
            _buildProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => auth.logout(), // FULL LOGOUT
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
