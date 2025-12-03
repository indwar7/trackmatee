// bookings/booking_screen.dart
import 'package:flutter/material.dart';


class BookingScreen extends StatelessWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Booking Type'),
        elevation: 0,
        backgroundColor: Colors.deepPurple[200],
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BookingTypeCard(
            title: 'Flight Booking',
            subtitle: 'Book domestic and international flights',
            icon: Icons.flight,
            color: Colors.black87,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const FlightBookingScreen(),
              //   ),
              // );
            },
          ),
          const SizedBox(height: 16),
          BookingTypeCard(
            title: 'Hotel Booking',
            subtitle: 'Find and book hotels worldwide',
            icon: Icons.hotel,
            color: Colors.black87,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const HotelBookingScreen(),
              //   ),
              // );
            },
          ),
          const SizedBox(height: 16),
          BookingTypeCard(
            title: 'Bus Booking',
            subtitle: 'Book bus tickets across cities',
            icon: Icons.directions_bus,
            color: Colors.black87,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const BusBookingScreen(),
              //   ),
              // );
            },
          ),
          const SizedBox(height: 16),
          BookingTypeCard(
            title: 'Cab Booking',
            subtitle: 'Book cabs for local and outstation',
            icon: Icons.local_taxi,
            color: Colors.black87,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const CabBookingScreen(),
              //   ),
              // );
            },
          ),
          const SizedBox(height: 16),
          BookingTypeCard(
            title: 'Train Booking',
            subtitle: 'Book train tickets easily',
            icon: Icons.train,
            color: Colors.black87,
            onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const TrainBookingScreen(),
                  //   ),
                  // );
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