// bookings/booking_screen.dart
import 'package:flutter/material.dart';
import 'flight_booking_screen.dart';
import 'hotel_booking_screen.dart';
import 'bus_booking_screen.dart';
import 'cab_booking_screen.dart';
import 'train_booking_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Booking Type'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BookingTypeCard(
            title: 'Flight Booking',
            subtitle: 'Book domestic and international flights',
            icon: Icons.flight,
            color: const Color(0xFF1A73E8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlightBookingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          BookingTypeCard(
            title: 'Hotel Booking',
            subtitle: 'Find and book hotels worldwide',
            icon: Icons.hotel,
            color: const Color(0xFF4CAF50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HotelBookingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          BookingTypeCard(
            title: 'Bus Booking',
            subtitle: 'Book bus tickets across cities',
            icon: Icons.directions_bus,
            color: const Color(0xFFFF9800),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusBookingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          BookingTypeCard(
            title: 'Cab Booking',
            subtitle: 'Book cabs for local and outstation',
            icon: Icons.local_taxi,
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CabBookingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          BookingTypeCard(
            title: 'Train Booking',
            subtitle: 'Book train tickets easily',
            icon: Icons.train,
            color: const Color(0xFFE91E63),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainBookingScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BookingTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const BookingTypeCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}