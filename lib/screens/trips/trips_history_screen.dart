import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = [
      {
        'from': 'Delhi',
        'to': 'Gurgaon',
        'date': 'Nov 29, 2025',
        'time': '09:30 AM',
        'distance': '28 km',
        'cost': '₹450',
        'co2': '2.5 kg',
        'mode': 'Car',
      },
      {
        'from': 'Gurgaon',
        'to': 'Delhi',
        'date': 'Nov 28, 2025',
        'time': '06:45 PM',
        'distance': '28 km',
        'cost': '₹420',
        'co2': '2.4 kg',
        'mode': 'Car',
      },
      {
        'from': 'Delhi',
        'to': 'Noida',
        'date': 'Nov 27, 2025',
        'time': '11:00 AM',
        'distance': '22 km',
        'cost': '₹350',
        'co2': '1.8 kg',
        'mode': 'Metro',
      },
      {
        'from': 'Noida',
        'to': 'Delhi',
        'date': 'Nov 27, 2025',
        'time': '05:30 PM',
        'distance': '22 km',
        'cost': '₹350',
        'co2': '1.8 kg',
        'mode': 'Metro',
      },
      {
        'from': 'Delhi',
        'to': 'Gurgaon',
        'date': 'Nov 26, 2025',
        'time': '08:15 AM',
        'distance': '28 km',
        'cost': '₹480',
        'co2': '2.6 kg',
        'mode': 'Car',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Trip History',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats Summary
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Total Trips', '45', Icons.directions_car),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white30,
                    ),
                    Expanded(
                      child: _buildStatItem('Distance', '1,240 km', Icons.route),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white30,
                    ),
                    Expanded(
                      child: _buildStatItem('CO₂', '43 kg', Icons.eco),
                    ),
                  ],
                ),
              ),
            ),

            // Trips List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Show trip details
                            _showTripDetails(context, trip);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Route Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: Color(0xFF7C3AED),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                trip['from']!,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.arrow_downward,
                                                color: Colors.grey,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                trip['distance']!,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                trip['to']!,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Mode Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C3AED).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        trip['mode']!,
                                        style: const TextStyle(
                                          color: Color(0xFF7C3AED),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                                Divider(color: Colors.grey[300], thickness: 1),
                                const SizedBox(height: 12),

                                // Trip Stats
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          trip['date']!,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          trip['time']!,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          trip['cost']!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7C3AED),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.eco,
                                                size: 12,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                trip['co2']!,
                                                style: const TextStyle(
                                                  fontSize: 11,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
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
    );
  }

  void _showTripDetails(BuildContext context, Map<String, String> trip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('From', trip['from']!),
            _buildDetailRow('To', trip['to']!),
            _buildDetailRow('Date', trip['date']!),
            _buildDetailRow('Time', trip['time']!),
            _buildDetailRow('Distance', trip['distance']!),
            _buildDetailRow('Cost', trip['cost']!),
            _buildDetailRow('CO₂ Emission', trip['co2']!),
            _buildDetailRow('Mode', trip['mode']!),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}