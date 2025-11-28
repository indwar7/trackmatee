import 'package:flutter/material.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location icon with pin
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.place,
                    size: 50,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Allow TrackMate to access this\ndevice\'s location?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLocationOption(
                      icon: Icons.my_location,
                      label: 'Precise',
                      isSelected: true,
                    ),
                    _buildLocationOption(
                      icon: Icons.location_on,
                      label: 'Approximate',
                      isSelected: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPermissionButton(
                  'While using the app',
                  onTap: () => _handlePermission(context, 'whileInUse'),
                ),
                const SizedBox(height: 12),
                _buildPermissionButton(
                  'Only this time',
                  onTap: () => _handlePermission(context, 'once'),
                ),
                const SizedBox(height: 12),
                _buildPermissionButton(
                  'Don\'t allow',
                  onTap: () => _handlePermission(context, 'deny'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade100 : Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
          child: Icon(
            icon,
            size: 32,
            color: isSelected ? Colors.blue : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _handlePermission(BuildContext context, String type) {
    print('Permission button clicked: $type');

    if (type == 'deny') {
      // Go directly to welcome screen
      Navigator.of(context).pushReplacementNamed('/welcome');
    } else {
      // Go to battery optimization screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const BatteryOptimizationScreen(),
        ),
      );
    }
  }
}

class BatteryOptimizationScreen extends StatelessWidget {
  const BatteryOptimizationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.battery_alert,
                    size: 48,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Allow TrackMate to optimise battery\nusage.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Icon(
                    Icons.battery_charging_full,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                _buildPermissionButton(
                  'While using the app',
                  onTap: () => _handlePermission(context, 'allow'),
                ),
                const SizedBox(height: 12),
                _buildPermissionButton(
                  'Only this time',
                  onTap: () => _handlePermission(context, 'once'),
                ),
                const SizedBox(height: 12),
                _buildPermissionButton(
                  'Don\'t allow',
                  onTap: () => _handlePermission(context, 'deny'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _handlePermission(BuildContext context, String type) {
    print('Battery permission button clicked: $type');
    // All options go to welcome screen
    Navigator.of(context).pushReplacementNamed('/welcome');
  }
}