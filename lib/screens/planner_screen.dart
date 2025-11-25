import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackmate_app/screens/planner/add_trip_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  // Mock data for planned trips
  final plannedTrips = [
    {
      'date': 'Dec 17, 2024',
      'time': '7:47 PM',
      'start': 'Pocket 1, Santa Vihar, New Delhi, Delhi, India',
      'end': '27th Avenue, Adhyatmik Nagar, Ghaziabad'
    },
    {
      'date': 'Dec 18, 2024',
      'time': '9:00 AM',
      'start': 'Cyber Hub, Gurgaon, Haryana, India',
      'end': 'Connaught Place, New Delhi, Delhi, India'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'My Trips',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planned Trips',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const AddTripScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ADD TRIP',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: plannedTrips.length,
                itemBuilder: (context, index) {
                  return _buildTripCard(plannedTrips[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, String> trip) {
    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trip['date']}  ${trip['time']}',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            _buildTripDetailRow(Icons.trip_origin, trip['start']!),
            const SizedBox(height: 8),
            _buildTripDetailRow(Icons.location_on, trip['end']!),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Handle start trip action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
