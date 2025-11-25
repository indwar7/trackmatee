// Travel Booking Screens
// This file contains all travel booking related screens and widgets

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Export controllers and screens
export 'travel_booking_controller.dart';
export 'tours_screen.dart';

// ============ MODELS ============
class Flight {
  final String id;
  final String airline;
  final String departureTime;
  final String arrivalTime;
  final String from;
  final String to;
  final double price;
  final int duration; // in minutes
  final String flightNumber;
  final String departureDate;
  final String arrivalDate;
  final String stops;
  final String cabinClass;
  final String? airlineLogo;
  final bool isRefundable;
  final double baggageAllowance;
  final double cabinBaggageAllowance;

  Flight({
    required this.id,
    required this.airline,
    required this.departureTime,
    required this.arrivalTime,
    required this.from,
    required this.to,
    required this.price,
    required this.duration,
    required this.flightNumber,
    required this.departureDate,
    required this.arrivalDate,
    required this.stops,
    required this.cabinClass,
    this.airlineLogo,
    this.isRefundable = false,
    this.baggageAllowance = 20.0,
    this.cabinBaggageAllowance = 7.0,
  });
}

class Hotel {
  final String id;
  final String name;
  final String location;
  final double rating;
  final double pricePerNight;
  final String imageUrl;
  final List<String> amenities;
  final bool isFavorite;
  final int reviewCount;
  final double distanceFromCenter; // in km

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerNight,
    required this.imageUrl,
    required this.amenities,
    this.isFavorite = false,
    this.reviewCount = 0,
    this.distanceFromCenter = 0.0,
  });
}

class TourPackage {
  final String id;
  final String destination;
  final int days;
  final double price;
  final String image;
  final List<String> highlights;
  bool isBookmarked;

  TourPackage({
    required this.id,
    required this.destination,
    required this.days,
    required this.price,
    required this.image,
    required this.highlights,
    this.isBookmarked = false,
  });
}

// ============ SCREENS ============
class TravelBookingScreen extends StatelessWidget {
  const TravelBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Your Trip'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.flight), text: 'Flights'),
              Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
              Tab(icon: Icon(Icons.explore), text: 'Tours'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FlightsTab(),
            HotelsTab(),
            ToursTab(),
          ],
        ),
      ),
    );
  }
}

class FlightsTab extends StatelessWidget {
  const FlightsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Flights Tab'));
  }
}

class HotelsTab extends StatelessWidget {
  const HotelsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Hotels Tab'));
  }
}

class ToursTab extends StatelessWidget {
  const ToursTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tours Tab'));
  }
}
