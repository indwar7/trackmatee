import 'package:flutter/material.dart';

// Data model for a single trip
class Trip {
  final String from;
  final String to;
  final String date;
  final String time;
  final String avatarUrl;

  Trip({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.avatarUrl,
  });
}

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({Key? key}) : super(key: key);

  // Mock data based on your screenshot
  static final List<Trip> _trips = [
    Trip(from: 'Delhi', to: 'Ghaziabad', date: 'Mon, Nov 16', time: '7:00 pm', avatarUrl: 'https://placehold.co/100x100/png'),
    Trip(from: 'Meerut', to: 'Ghaziabad', date: 'Mon, Nov 15', time: '6:00 pm', avatarUrl: 'https://placehold.co/100x100/png'),
    Trip(from: 'Meerut', to: 'Ghaziabad', date: 'Mon, Nov 15', time: '7:00 pm', avatarUrl: 'https://placehold.co/100x100/png'),
    Trip(from: 'Noida', to: 'Ghaziabad', date: 'Mon, Nov 14', time: '7:00 pm', avatarUrl: 'https://placehold.co/100x100/png'),
    Trip(from: 'Meerut', to: 'Ghaziabad', date: 'Mon, Nov 13', time: '6:30 pm', avatarUrl: 'https://placehold.co/100x100/png'),
    Trip(from: 'Delhi', to: 'Ghaziabad', date: 'Mon, Nov 16', time: '7:00 pm', avatarUrl: 'https://placehold.co/100x100/png'),
    Trip(from: 'Meerut', to: 'Ghaziabad', date: 'Mon, Nov 15', time: '6:00 pm', avatarUrl: 'https://placehold.co/100x100/png'),
    Trip(from: 'Meerut', to: 'Ghaziabad', date: 'Mon, Nov 15', time: '7:00 pm', avatarUrl: 'https://placehold.co/100x100/png'),
    Trip(from: 'Noida', to: 'Ghaziabad', date: 'Mon, Nov 14', time: '7:00 pm', avatarUrl: 'https://placehold.co_100x100/png'),
    Trip(from: 'Meerut', to: 'Ghaziabad', date: 'Mon, Nov 13', time: '6:30 pm', avatarUrl: 'https://placehold.co/100x100/png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background from screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(_trips[index]);
        },
      ),
    );
  }

  // A single trip card widget
  Widget _buildTripCard(Trip trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E), // Card color from screenshot
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Stacked avatar and car icon
          SizedBox(
            width: 60,
            height: 40,
            child: Stack(
              children: [
                // Car icon
                const Positioned(
                  left: 20,
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                // Avatar
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(trip.avatarUrl),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Trip details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.from} → ${trip.to}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      trip.date,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, color: Colors.grey, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      trip.time,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
