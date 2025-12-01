import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoTripTrackingScreen extends StatefulWidget {
  const AutoTripTrackingScreen({super.key});

  @override
  State<AutoTripTrackingScreen> createState() => _AutoTripTrackingScreenState();
}

class _AutoTripTrackingScreenState extends State<AutoTripTrackingScreen> {
  bool isTracking = false;
  String currentLocation = 'San Francisco';
  double distance = 0.3;

  void startTracking() {
    setState(() {
      isTracking = true;
    });
    // Here you would start actual GPS tracking
    // This is where you'll integrate with location services
  }

  void stopTracking() {
    setState(() {
      isTracking = false;
    });
    // Here you would stop GPS tracking
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Auto Trip Tracking',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Main Tracking Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Map Illustration with Car
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Simple map grid
                          Center(
                            child: Icon(
                              Icons.map,
                              size: 120,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          // Car icon
                          Positioned(
                            bottom: 40,
                            right: 40,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.yellow[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                          ),
                          // Location marker
                          Positioned(
                            top: 40,
                            left: 40,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Text
                    if (!isTracking)
                      Column(
                        children: [
                          const Text(
                            'Tanvee, while auto tracking the following will be continuously monitored:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('• Location'),
                          _buildInfoRow('• Battery utilization'),
                          _buildInfoRow('• Speed'),
                          const SizedBox(height: 24),
                          const Text(
                            'Confirm your choice to start tracking.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentLocation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$distance mi',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, color: Colors.green, size: 12),
                                SizedBox(width: 8),
                                Text(
                                  'Tracking Active',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (isTracking) {
                      stopTracking();
                    } else {
                      startTracking();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTracking
                        ? const Color(0xFF475569)
                        : const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isTracking ? 'EXIT' : 'START',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats Row (only show when tracking)
              if (isTracking)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Speed', '45 km/h', Icons.speed),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Battery', '85%', Icons.battery_full),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Time', '12 min', Icons.access_time),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF7C3AED), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}