import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({Key? key}) : super(key: key);

  @override
  _HotelsScreenState createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final TextEditingController _locationController = TextEditingController();
  DateTimeRange? _dateRange;
  int _adults = 2;
  int _rooms = 1;
  String _selectedSort = 'Recommended';
  double _priceRange = 10000;
  final List<String> _amenities = [];

  final List<Map<String, dynamic>> _hotels = [
    {
      'name': 'Taj Lands End',
      'location': 'Bandra West, Mumbai',
      'rating': 4.5,
      'price': 15000,
      'image': 'assets/hotel1.jpg',
      'reviews': 1248,
      'isWishlisted': false,
      'amenities': ['Free WiFi', 'Pool', 'Spa', 'Restaurant', 'Airport Shuttle'],
    },
    {
      'name': 'The Oberoi',
      'location': 'Nariman Point, Mumbai',
      'rating': 4.7,
      'price': 22000,
      'image': 'assets/hotel2.jpg',
      'reviews': 986,
      'isWishlisted': true,
      'amenities': ['Free WiFi', 'Pool', 'Spa', 'Restaurant', 'Gym', 'Beach Access'],
    },
    {
      'name': 'Trident Nariman Point',
      'location': 'Nariman Point, Mumbai',
      'rating': 4.4,
      'price': 12000,
      'image': 'assets/hotel3.jpg',
      'reviews': 856,
      'isWishlisted': false,
      'amenities': ['Free WiFi', 'Pool', 'Restaurant', 'Gym'],
    },
  ];

  final List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low',
    'Popularity'
  ];

  final List<String> _allAmenities = [
    'Free WiFi',
    'Pool',
    'Spa',
    'Restaurant',
    'Gym',
    'Parking',
    'Airport Shuttle',
    'Beach Access',
    'Room Service',
    'Bar/Lounge'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Find Hotels',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                color: Colors.purple,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Location
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              hintText: 'Where do you want to stay?',
                              prefixIcon: const Icon(Icons.location_on, color: Colors.purple),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Date Range
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    // Show date range picker
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Check-in - Check-out',
                                      prefixIcon: const Icon(Icons.calendar_today, color: Colors.purple),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      _dateRange == null
                                          ? 'Select dates'
                                          : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Guests and Rooms
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _adults,
                                  decoration: InputDecoration(
                                    labelText: 'Guests',
                                    prefixIcon: const Icon(Icons.person, color: Colors.purple),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: List.generate(10, (index) => index + 1)
                                      .map((value) => DropdownMenuItem(
                                            value: value,
                                            child: Text('$value ${value == 1 ? 'Guest' : 'Guests'}'),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _adults = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _rooms,
                                  decoration: InputDecoration(
                                    labelText: 'Rooms',
                                    prefixIcon: const Icon(Icons.king_bed, color: Colors.purple),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: List.generate(5, (index) => index + 1)
                                      .map((value) => DropdownMenuItem(
                                            value: value,
                                            child: Text('$value ${value == 1 ? 'Room' : 'Rooms'}'),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _rooms = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Search Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle search
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'SEARCH HOTELS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSort,
                          decoration: InputDecoration(
                            labelText: 'Sort by',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _sortOptions
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSort = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filter Button
                      OutlinedButton.icon(
                        onPressed: () {
                          _showFilterBottomSheet(context);
                        },
                        icon: const Icon(Icons.filter_list, color: Colors.purple),
                        label: const Text('Filters', style: TextStyle(color: Colors.purple)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.purple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Hotel List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final hotel = _hotels[index];
                return _buildHotelCard(hotel);
              },
              childCount: _hotels.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Image
          Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  image: DecorationImage(
                    image: AssetImage(hotel['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    hotel['isWishlisted'] ? Icons.favorite : Icons.favorite_border,
                    color: hotel['isWishlisted'] ? Colors.red : Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      hotel['isWishlisted'] = !hotel['isWishlisted'];
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel['rating']} (${hotel['reviews']} reviews)',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Hotel Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Name and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hotel['name'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹${hotel['price'].toString()}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hotel['location'],
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Amenities
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (hotel['amenities'] as List<dynamic>).take(3).map((amenity) {
                    return Chip(
                      label: Text(
                        amenity,
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey[200],
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // View Deal Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle view deal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('VIEW DEAL'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            // Price Range
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Price Range (per night)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Slider(
              value: _priceRange,
              min: 1000,
              max: 50000,
              divisions: 49,
              label: '₹${_priceRange.round()}',
              onChanged: (value) {
                setState(() {
                  _priceRange = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('₹1000'),
                Text('₹50000'),
              ],
            ),
            const SizedBox(height: 16),
            // Amenities
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Amenities',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            // Amenity Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allAmenities.map((amenity) {
                final isSelected = _amenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _amenities.add(amenity);
                      } else {
                        _amenities.remove(amenity);
                      }
                    });
                  },
                  selectedColor: Colors.purple.withOpacity(0.2),
                  checkmarkColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.purple : Colors.black87,
                  ),
                  side: BorderSide(
                    color: isSelected ? Colors.purple : Colors.grey[300]!,
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply filters
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'APPLY FILTERS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
