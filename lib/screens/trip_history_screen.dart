import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _trips = [];
  String _filterMode = 'all';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/trips/history/'),
        headers: api.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          setState(() {
            _trips = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else if (data is Map && data['trips'] != null) {
          setState(() {
            _trips = List<Map<String, dynamic>>.from(data['trips']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _trips = [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() {
        _trips = [];
        _isLoading = false;
      });
      _showError('Failed to load trip history');
    }
  }

  List<Map<String, dynamic>> get _filteredTrips {
    var filtered = _trips;

    // Filter by mode
    if (_filterMode != 'all') {
      filtered = filtered.where((trip) {
        final mode = trip['mode_of_travel']?.toString().toLowerCase();
        return mode == _filterMode;
      }).toList();
    }

    // Filter by date range
    if (_filterStartDate != null) {
      filtered = filtered.where((trip) {
        try {
          final tripDate = DateTime.parse(trip['start_time']);
          return tripDate.isAfter(_filterStartDate!) ||
              tripDate.isAtSameMomentAs(_filterStartDate!);
        } catch (e) {
          return true;
        }
      }).toList();
    }

    if (_filterEndDate != null) {
      filtered = filtered.where((trip) {
        try {
          final tripDate = DateTime.parse(trip['start_time']);
          return tripDate.isBefore(_filterEndDate!.add(const Duration(days: 1)));
        } catch (e) {
          return true;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Summary
          if (_trips.isNotEmpty) _buildStatsCard(),

          // Trip List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTrips.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredTrips.length,
                itemBuilder: (context, index) {
                  return _buildTripCard(_filteredTrips[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalTrips = _trips.length;
    final totalDistance = _trips.fold<double>(
        0,
            (sum, trip) => sum + (double.tryParse(trip['distance_km']?.toString() ?? '0') ?? 0)
    );
    final totalCost = _trips.fold<double>(
        0,
            (sum, trip) => sum + (double.tryParse(trip['total_cost']?.toString() ?? '0') ?? 0)
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00adb5), Color(0xFF0f3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '📊 Your Trip Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.local_activity,
                value: totalTrips.toString(),
                label: 'Trips',
              ),
              _buildStatItem(
                icon: Icons.straighten,
                value: '${totalDistance.toStringAsFixed(1)} km',
                label: 'Distance',
              ),
              _buildStatItem(
                icon: Icons.currency_rupee,
                value: '₹${totalCost.toStringAsFixed(0)}',
                label: 'Total Cost',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _filterMode != 'all' || _filterStartDate != null
                ? 'No trips match your filters'
                : 'No trips yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterMode != 'all' || _filterStartDate != null
                ? 'Try adjusting your filters'
                : 'Start tracking your trips!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          if (_filterMode != 'all' || _filterStartDate != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterMode = 'all';
                  _filterStartDate = null;
                  _filterEndDate = null;
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final date = DateTime.tryParse(trip['start_time'] ?? '');
    final formattedDate = date != null
        ? DateFormat('MMM dd, yyyy').format(date)
        : 'Unknown date';
    final formattedTime = date != null
        ? DateFormat('hh:mm a').format(date)
        : 'Unknown time';

    final distance = trip['distance_km']?.toString() ?? '0';
    final duration = trip['duration_minutes']?.toString() ?? '0';
    final cost = trip['total_cost']?.toString() ?? '0';
    final mode = trip['mode_of_travel']?.toString().toLowerCase() ?? 'unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showTripDetails(trip),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF16213e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00adb5).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00adb5).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getModeIcon(mode),
                      color: const Color(0xFF00adb5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip['start_location_name'] ?? trip['start_location'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trip['end_location_name'] ?? trip['end_location'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTripStat(Icons.calendar_today, formattedDate),
                  const SizedBox(width: 16),
                  _buildTripStat(Icons.access_time, formattedTime),
                ],
              ),
              const Divider(height: 24, color: Colors.white24),
              Row(
                children: [
                  Expanded(
                    child: _buildTripStat(
                      Icons.straighten,
                      '$distance km',
                    ),
                  ),
                  Expanded(
                    child: _buildTripStat(
                      Icons.timer,
                      '$duration min',
                    ),
                  ),
                  Expanded(
                    child: _buildTripStat(
                      Icons.currency_rupee,
                      '₹$cost',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getModeIcon(String? mode) {
    switch (mode?.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
        return Icons.two_wheeler;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'metro':
        return Icons.subway;
      case 'walk':
        return Icons.directions_walk;
      default:
        return Icons.location_on;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Trips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Mode filter
                const Text(
                  'Mode of Travel',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip('all', 'All', setModalState),
                    _buildFilterChip('car', 'Car', setModalState),
                    _buildFilterChip('bike', 'Bike', setModalState),
                    _buildFilterChip('bus', 'Bus', setModalState),
                    _buildFilterChip('train', 'Train', setModalState),
                  ],
                ),
                const SizedBox(height: 20),

                // Date range
                const Text(
                  'Date Range',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _filterStartDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => _filterStartDate = picked);
                            setState(() => _filterStartDate = picked);
                          }
                        },
                        child: Text(
                          _filterStartDate != null
                              ? DateFormat('MMM dd').format(_filterStartDate!)
                              : 'Start Date',
                        ),
                      ),
                    ),
                    const Text('to', style: TextStyle(color: Colors.white70)),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _filterEndDate ?? DateTime.now(),
                            firstDate: _filterStartDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => _filterEndDate = picked);
                            setState(() => _filterEndDate = picked);
                          }
                        },
                        child: Text(
                          _filterEndDate != null
                              ? DateFormat('MMM dd').format(_filterEndDate!)
                              : 'End Date',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _filterMode = 'all';
                            _filterStartDate = null;
                            _filterEndDate = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00adb5),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, StateSetter setModalState) {
    final isSelected = _filterMode == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() => _filterMode = value);
        setState(() => _filterMode = value);
      },
      selectedColor: const Color(0xFF00adb5).withOpacity(0.3),
      checkmarkColor: const Color(0xFF00adb5),
    );
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Trip Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Start', trip['start_location_name'] ?? trip['start_location']),
                _buildDetailRow('Destination', trip['end_location_name'] ?? trip['end_location']),
                _buildDetailRow('Distance', '${trip['distance_km']} km'),
                _buildDetailRow('Duration', '${trip['duration_minutes']} minutes'),
                _buildDetailRow('Mode', trip['mode_of_travel'] ?? 'N/A'),
                _buildDetailRow('Purpose', trip['trip_purpose'] ?? 'N/A'),
                _buildDetailRow('Companions', trip['number_of_companions']?.toString() ?? '0'),
                if (trip['fuel_expense'] != null)
                  _buildDetailRow('Fuel Cost', '₹${trip['fuel_expense']}'),
                if (trip['parking_cost'] != null)
                  _buildDetailRow('Parking', '₹${trip['parking_cost']}'),
                if (trip['toll_cost'] != null)
                  _buildDetailRow('Toll', '₹${trip['toll_cost']}'),
                const Divider(color: Colors.white24, height: 32),
                _buildDetailRow('Total Cost', '₹${trip['total_cost']}', isTotal: true),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}// TODO Implement this library.