import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({Key? key}) : super(key: key);

  @override
  _FlightBookingScreenState createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  // Mock data for flights
  final flights = [
    {'airline': 'IndiGo', 'from': 'DEL', 'to': 'BOM', 'time': '08:30 - 10:45', 'price': '₹4,500'},
    {'airline': 'AirAsia', 'from': 'DEL', 'to': 'BOM', 'time': '09:15 - 11:30', 'price': '₹4,850'},
    {'airline': 'Vistara', 'from': 'DEL', 'to': 'BOM', 'time': '11:00 - 13:05', 'price': '₹5,200'},
    {'airline': 'SpiceJet', 'from': 'DEL', 'to': 'BOM', 'time': '12:45 - 14:55', 'price': '₹4,200'},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Book Flights',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchCard(),
          Expanded(
            child: ListView.builder(
              itemCount: flights.length,
              itemBuilder: (context, index) {
                return _buildFlightCard(flights[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'DEL → BOM',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle search action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard(Map<String, String> flight) {
    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.airplanemode_active, color: Color(0xFF8B5CF6), size: 32),
                const SizedBox(width: 12),
                Text(
                  flight['airline']!,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  flight['price']!,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(flight['from']!, '08:30'),
                const Icon(Icons.arrow_right_alt, color: Colors.white, size: 30),
                _buildTimeColumn(flight['to']!, '10:45'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String airport, String time) {
    return Column(
      children: [
        Text(
          airport,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          time,
          style: GoogleFonts.inter(color: Colors.grey[400]),
        ),
      ],
    );
  }
}
