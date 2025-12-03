import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Hotels',
        'icon': Icons.hotel_outlined,
        'color': const Color(0xFF6C5CE7),
      },
      {
        'title': 'Flights',
        'icon': Icons.flight_takeoff_outlined,
        'color': const Color(0xFF00B894),
      },
      {
        'title': 'Food',
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFFE84393),
      },
      {
        'title': 'Events',
        'icon': Icons.event_available_outlined,
        'color': const Color(0xFFFDCB6E),
      },
    ];

    final List<Map<String, dynamic>> popularDestinations = [
      {
        'image': 'assets/images/jaipur.png',
        'title': 'Jaipur, India',
        'rating': 4.8,
        'price': '₹3,500',
      },
      {
        'image': 'assets/images/mumbai.png',
        'title': 'Mumbai, India',
        'rating': 4.9,
        'price': '₹4,200',
      },
      {
        'image': 'assets/images/banglore.png',
        'title': 'Bangalore, India',
        'rating': 4.7,
        'price': '₹3,800',
      },
    ];

    final List<Map<String, dynamic>> travelDeals = [
      {
        'title': 'Summer Special',
        'description': 'Get 20% off on all destinations',
        'discount': '20% OFF',
        'color': const Color(0xFF6C5CE7),
        'icon': Icons.local_offer_outlined,
      },
      {
        'title': 'Weekend Getaway',
        'description': 'Special weekend packages',
        'discount': '15% OFF',
        'color': const Color(0xFF00B894),
        'icon': Icons.weekend_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explore the world',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Categories
              Text(
                'Categories',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Categories Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: categories.map((category) => _buildCategoryItem(
                  category['icon'],
                  category['title'],
                  category['color'],
                )).toList(),
              ),
              const SizedBox(height: 30),

              // Popular Destinations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Destinations',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6C5CE7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Popular Destinations List
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: popularDestinations.map((destination) => 
                    _buildDestinationCard(
                      destination['image'],
                      destination['title'],
                      destination['price'],
                      destination['rating'],
                    ),
                  ).toList(),
                ),
              ),
              const SizedBox(height: 30),

              // Travel Deals
              Text(
                'Travel Deals',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Travel Deals List
              ...travelDeals.map((deal) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDealCard(
                  deal['title'],
                  deal['description'],
                  deal['discount'],
                  deal['icon'],
                  deal['color'],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(String imagePath, String title, String price, double rating) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with rating
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  imagePath,
                  width: 160,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 160,
                    height: 120,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'From $price',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6C5CE7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(String title, String subtitle, String discount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Deal chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              discount,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}