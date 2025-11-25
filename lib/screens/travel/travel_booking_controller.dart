import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============ MODELS ============
class Flight {
  final String id;
  final String airline;
  final String departureTime;
  final String arrivalTime;
  final String from;
  final String to;
  final double price;
  final int duration;
  final String stops;

  Flight({
    required this.id,
    required this.airline,
    required this.departureTime,
    required this.arrivalTime,
    required this.from,
    required this.to,
    required this.price,
    required this.duration,
    required this.stops,
  });
}

class Hotel {
  final String id;
  final String name;
  final String location;
  final double rating;
  final double pricePerNight;
  final String image;
  final List<String> amenities;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.pricePerNight,
    required this.image,
    required this.amenities,
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

class BookingItem {
  final String title;
  final double price;

  BookingItem({
    required this.title,
    required this.price,
  });
}

// ============ CONTROLLERS ============
class FlightController extends GetxController {
  final flights = <Flight>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFlights();
  }

  Future<void> fetchFlights() async {
    try {
      isLoading.value = true;
      // Mock data - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      flights.value = [
        // Add mock flight data here
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch flights: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class HotelController extends GetxController {
  final hotels = <Hotel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    try {
      isLoading.value = true;
      // Mock data - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      hotels.value = [
        // Add mock hotel data here
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch hotels: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class TourController extends GetxController {
  final tours = <TourPackage>[].obs;
  final filteredTours = <TourPackage>[].obs;
  final cartTours = <TourPackage>[].obs;
  final bookmarkedTours = <TourPackage>[].obs;
  final isLoading = false.obs;
  final selectedDuration = 0.obs;
  final minPrice = 0.0.obs;
  final maxPrice = 100000.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTours();
  }

  Future<void> fetchTours() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      tours.value = [
        TourPackage(
          id: '1',
          destination: 'Goa Beach Tour',
          days: 5,
          price: 14999,
          image: '🏖️',
          highlights: ['Beach', 'Water Sports', 'Nightlife', 'Seafood'],
        ),
        TourPackage(
          id: '2',
          destination: 'Himalayan Trek',
          days: 7,
          price: 24999,
          image: '⛰️',
          highlights: ['Trekking', 'Camping', 'Nature', 'Adventure'],
        ),
        TourPackage(
          id: '3',
          destination: 'Kerala Backwaters',
          days: 4,
          price: 18999,
          image: '🌴',
          highlights: ['Backwaters', 'Houseboat', 'Spice Garden', 'Beaches'],
        ),
      ];
      filteredTours.value = List.from(tours);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByDuration(int days) {
    if (days == 0) {
      filteredTours.value = List.from(tours);
    } else {
      filteredTours.value = tours.where((t) => t.days == days).toList();
    }
  }

  void filterByPrice(double min, double max) {
    filteredTours.value = tours
        .where((t) => t.price >= min && t.price <= max)
        .toList();
  }

  void toggleBookmark(TourPackage tour) {
    final index = tours.indexWhere((t) => t.id == tour.id);
    if (index != -1) {
      tours[index].isBookmarked = !tours[index].isBookmarked;
      tours.refresh();
      
      if (tours[index].isBookmarked) {
        bookmarkedTours.add(tour);
      } else {
        bookmarkedTours.removeWhere((t) => t.id == tour.id);
      }
    }
  }

  void addToCart(TourPackage tour) {
    cartTours.add(tour);
    Get.snackbar(
      'Added to Cart',
      '${tour.destination} tour added',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void proceedToBooking() {
    if (cartTours.isEmpty) {
      Get.snackbar('Error', 'Please select a tour');
      return;
    }
    
    double totalPrice = cartTours.fold(0, (sum, tour) => sum + tour.price);
    Get.to(
      () => BookingConfirmationScreen(
        bookingType: 'Tour',
        items: cartTours
            .map((tour) => BookingItem(
                  title: tour.destination,
                  price: tour.price,
                ))
            .toList(),
        subtotal: totalPrice,
        tax: totalPrice * 0.18, // 18% tax
        total: totalPrice * 1.18,
        onConfirm: () {
          // Process booking
          final bookingId = 'TM${DateTime.now().millisecondsSinceEpoch}';
          Get.off(() => BookingSuccessScreen(
                bookingId: bookingId,
                bookingType: 'Tour',
              ));
        },
      ),
    );
  }
}

// ============ SCREENS ============
class BookingConfirmationScreen extends StatelessWidget {
  final String bookingType;
  final List<BookingItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final VoidCallback onConfirm;

  const BookingConfirmationScreen({
    Key? key,
    required this.bookingType,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Confirm $bookingType Booking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '₹${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )),
            const Divider(color: Colors.white24, height: 32),
            _buildPriceRow('Subtotal', subtotal),
            _buildPriceRow('Tax (18%)', tax),
            const Divider(color: Colors.white24, height: 32),
            _buildPriceRow('Total', total, isTotal: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String bookingType;

  const BookingSuccessScreen({
    Key? key,
    required this.bookingId,
    required this.bookingType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your $bookingType booking has been confirmed',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Booking ID: $bookingId',
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.until((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
