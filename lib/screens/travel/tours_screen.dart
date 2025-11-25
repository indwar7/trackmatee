import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trackmate_app/screens/travel/travel_booking_controller.dart';

class ToursScreen extends StatelessWidget {
  const ToursScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TourController());
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tour Packages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _showCart(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(controller),
          
          // Tour List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredTours.isEmpty) {
                return const Center(
                  child: Text(
                    'No tours found',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredTours.length,
                itemBuilder: (context, index) {
                  final tour = controller.filteredTours[index];
                  return _buildTourCard(context, tour, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilters(TourController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration Filter
          Text(
            'Duration (Days)',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', () => controller.filterByDuration(0)),
                const SizedBox(width: 8),
                _buildFilterChip('1-3', () => controller.filterByDuration(3)),
                const SizedBox(width: 8),
                _buildFilterChip('4-7', () => controller.filterByDuration(7)),
                const SizedBox(width: 8),
                _buildFilterChip('8+', () => controller.filterByDuration(8)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Price Range
          Text(
            'Price Range',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', () => controller.filterByPrice(0, 100000)),
                const SizedBox(width: 8),
                _buildFilterChip('Under ₹10K', () => controller.filterByPrice(0, 10000)),
                const SizedBox(width: 8),
                _buildFilterChip('₹10K-20K', () => controller.filterByPrice(10000, 20000)),
                const SizedBox(width: 8),
                _buildFilterChip('Over ₹20K', () => controller.filterByPrice(20000, 100000)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTourCard(BuildContext context, TourPackage tour, TourController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      color: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tour Image
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(tour.image),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) => 
                    const Icon(Icons.image_not_supported, size: 60, color: Colors.white30),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => controller.toggleBookmark(tour),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        tour.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: tour.isBookmarked ? const Color(0xFF8B5CF6) : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tour Details
          Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 12, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Duration
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        tour.destination,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tour.days} ${tour.days > 1 ? 'Days' : 'Day'}' ,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Highlights
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tour.highlights.map((highlight) => Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.45,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          highlight,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Price and Book Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting from',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: 11,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${NumberFormat('#,##0').format(tour.price)}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.addToCart(tour);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width < 360 ? 14.0 : 18.0,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 360 ? 12 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
  
  void _showCart(BuildContext context, TourController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Cart',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cart Items
            Obx(() {
              if (controller.cartTours.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('Your cart is empty', style: TextStyle(color: Colors.white70)),
                );
              }
              
              return Column(
                children: [
                  ...controller.cartTours.map((tour) => ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF1F2937),
                      ),
                      child: Center(child: Text(tour.image, style: const TextStyle(fontSize: 20))),
                    ),
                    title: Text(
                      tour.destination,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${tour.days} days • ₹${tour.price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => controller.cartTours.remove(tour),
                    ),
                  )),
                  
                  const Divider(color: Colors.white12, height: 32),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total (${controller.cartTours.length} items):',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${(controller.cartTours.fold(0.0, (sum, tour) => sum + tour.price)).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        controller.proceedToBooking();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
