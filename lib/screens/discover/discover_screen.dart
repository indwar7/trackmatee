import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'title': 'Hotels', 'icon': Icons.hotel, 'color': Colors.purpleAccent},
      {'title': 'Flights', 'icon': Icons.flight_takeoff, 'color': Colors.tealAccent},
      {'title': 'Food', 'icon': Icons.restaurant, 'color': Colors.pinkAccent},
      {'title': 'Events', 'icon': Icons.event, 'color': Colors.amberAccent},
    ];

    final List<Map<String, dynamic>> popularDestinations = [
      {'image': 'assets/images/jaipur.png', 'title': 'Jaipur, India', 'price': '₹3,500', 'rating': 4.8},
      {'image': 'assets/images/mumbai.png', 'title': 'Mumbai, India', 'price': '₹4,200', 'rating': 4.9},
      {'image': 'assets/images/banglore.png', 'title': 'Bangalore, India', 'price': '₹3,800', 'rating': 4.7},
    ];

    final List<Map<String, dynamic>> deals = [
      {'title': 'Summer Special', 'subtitle': '20% OFF on hotels', 'icon': Icons.local_offer, 'color': Colors.purpleAccent},
      {'title': 'Weekend Trip', 'subtitle': '15% OFF on flights', 'icon': Icons.beach_access, 'color': Colors.tealAccent},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ---------------- HEADER ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discover',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// ---------------- CATEGORY CHIPS ----------------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((c) {
                    return _categoryChip(c['icon'], c['title'], c['color']);
                  }).toList(),
                ),
              ),

              const SizedBox(height: 28),

              /// ---------------- POPULAR DESTINATIONS ----------------
              _sectionHeader("Popular Destinations"),

              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: popularDestinations.map((d) {
                    return _destinationCard(
                      d['image'],
                      d['title'],
                      d['price'],
                      d['rating'],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              /// ---------------- DEALS ----------------
              _sectionHeader("Travel Deals"),

              const SizedBox(height: 16),
              Column(
                children: deals.map((deal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _dealCard(
                      deal['title'],
                      deal['subtitle'],
                      deal['icon'],
                      deal['color'],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===================================================================
  /// CATEGORY CHIP
  /// ===================================================================

  Widget _categoryChip(IconData icon, String title, Color glowColor) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: glowColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: glowColor, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  /// ===================================================================
  /// DESTINATION CARD
  /// ===================================================================

  Widget _destinationCard(String img, String title, String price, double rating) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              img,
              height: 140,
              width: 180,
              fit: BoxFit.cover,
            ),
          ),

          /// DETAILS
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        color: Colors.purpleAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ===================================================================
  /// DEAL CARD (Glassmorphism Card)
  /// ===================================================================

  Widget _dealCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          /// ICON BOX
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(width: 18),

          /// TEXT
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
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                )
              ],
            ),
          ),

          /// ARROW
          const Icon(
            Icons.chevron_right,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

  /// ===================================================================
  /// SECTION HEADER
  /// ===================================================================

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          "See all",
          style: GoogleFonts.poppins(
            color: Colors.purpleAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
