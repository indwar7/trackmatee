import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackmate_app/screens/travel/flights_screen.dart';
import 'package:trackmate_app/screens/travel/hotels_screen.dart';
import 'package:trackmate_app/screens/travel/tours_screen.dart';

class TravelHomeScreen extends StatelessWidget {
  const TravelHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Explore Travel',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
            tabs: const [
              Tab(icon: Icon(Icons.flight), text: 'Flights'),
              Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
              Tab(icon: Icon(Icons.explore), text: 'Tours'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FlightsScreen(),
            HotelsScreen(),
            ToursScreen(),
          ],
        ),
      ),
    );
  }
}
