import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8D9FF), // Lavender background
              borderRadius: BorderRadius.circular(22),
            ),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "Terms of usage",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Helvetica",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "By using this app, you agree to the following:",
                    style: TextStyle(
                      fontFamily: "Helvetica",
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _bullet(
                      "Location Data: You consent to the app accessing your real-time "
                          "location data via GPS/network for the purpose of tracking your "
                          "journey and providing location-based services."
                  ),

                  _bullet(
                      "Data Usage & Battery: You acknowledge the app uses battery "
                          "optimization features and may run in the background. This may "
                          "impact battery life and data usage."
                  ),

                  _bullet(
                      "Privacy: We handle your location data according to our Privacy "
                          "Policy, mainly for service and aggregated analysis."
                  ),

                  _bullet(
                      "Disclaimer: The app is provided “as is.” We are not responsible "
                          "for damages or inaccuracies caused by app data."
                  ),

                  _bullet(
                      "Termination: We may suspend or terminate your access if these "
                          "terms are violated."
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6), // Purple button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "CONFIRM",
                        style: TextStyle(
                          fontFamily: "Helvetica",
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // 🔥 FIXED: High-contrast text
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Bullet text widget
  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: "Helvetica",
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
