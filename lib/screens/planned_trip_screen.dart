import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class PlannedTripScreen extends StatefulWidget {
  const PlannedTripScreen({super.key});

  @override
  State<PlannedTripScreen> createState() => _PlannedTripScreenState();
}

class _PlannedTripScreenState extends State<PlannedTripScreen> {
  GoogleMapController? _mapController;

  LatLng? _startPoint;
  LatLng? _endPoint;
  String? _startAddress;
  String? _endAddress;

  final Set<Marker> _markers = {};
  bool _showForm = false;

  // Form fields
  final _tripNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  String? _modeOfTravel;
  String? _tripPurpose;
  int _companions = 0;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate;

  bool _isLoading = false;

  final List<Map<String, dynamic>> _modes = [
    {'value': 'car', 'label': '🚗 Car'},
    {'value': 'bike', 'label': '🏍 Bike'},
    {'value': 'bus', 'label': '🚌 Bus'},
    {'value': 'train', 'label': '🚂 Train'},
    {'value': 'metro', 'label': '🚇 Metro'},
    {'value': 'walk', 'label': '🚶 Walk'},
  ];

  final List<Map<String, String>> _purposes = [
    {'value': 'work', 'label': '💼 Work'},
    {'value': 'education', 'label': '📚 Education'},
    {'value': 'shopping', 'label': '🛍 Shopping'},
    {'value': 'social', 'label': '🎉 Social'},
    {'value': 'medical', 'label': '🏥 Medical'},
    {'value': 'personal', 'label': '📋 Personal'},
    {'value': 'vacation', 'label': '🏖 Vacation'},
  ];

  @override
  void dispose() {
    _mapController?.dispose();
    _tripNameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan a Trip'),
        centerTitle: true,
        actions: [
          if (_showForm)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => setState(() => _showForm = false),
            ),
        ],
      ),
      body: _showForm ? _buildForm() : _buildMapView(),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        FutureBuilder<LatLng>(
          future: _getCurrentLocation(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: snapshot.data!,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: _onMapTap,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            );
          },
        ),

        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildInstructionsCard(),
        ),

        if (_startPoint != null && _endPoint != null)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: CustomButton(
              text: 'Continue to Details',
              onPressed: () => setState(() => _showForm = true),
              color: const Color(0xFFf39c12),
            ),
          ),
      ],
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _startPoint == null
                ? '📍 Tap to select START location'
                : _endPoint == null
                ? '📍 Tap to select DESTINATION'
                : '✅ Route selected!',
            style: const TextStyle(
              color: Color(0xFFf39c12),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (_startAddress != null) ...[
            const SizedBox(height: 8),
            Text(
              'Start: $_startAddress',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (_endAddress != null) ...[
            const SizedBox(height: 4),
            Text(
              'Destination: $_endAddress',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Route Summary Card
          _buildRouteCard(),
          const SizedBox(height: 24),

          // Trip Name
          TextField(
            controller: _tripNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Trip Name *',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'e.g., Weekend Getaway',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: const Icon(Icons.label, color: Color(0xFFf39c12)),
              filled: true,
              fillColor: const Color(0xFF16213e),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'Add trip details...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: const Icon(Icons.description, color: Color(0xFFf39c12)),
              filled: true,
              fillColor: const Color(0xFF16213e),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Dates
          _buildSectionTitle('Travel Dates *'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Start Date',
                  date: _startDate,
                  onTap: _selectStartDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  label: 'End Date',
                  date: _endDate,
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mode of Travel
          _buildSectionTitle('Mode of Travel *'),
          const SizedBox(height: 12),
          _buildModeSelector(),
          const SizedBox(height: 24),

          // Trip Purpose
          _buildSectionTitle('Trip Purpose *'),
          const SizedBox(height: 12),
          _buildPurposeSelector(),
          const SizedBox(height: 24),

          // Companions
          _buildSectionTitle('Companions'),
          const SizedBox(height: 12),
          _buildCompanionSelector(),
          const SizedBox(height: 24),

          // Budget
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Estimated Budget',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: Colors.white),
              prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFFf39c12)),
              filled: true,
              fillColor: const Color(0xFF16213e),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showForm = false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFf39c12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Map',
                    style: TextStyle(color: Color(0xFFf39c12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Save Plan',
                  onPressed: _submitForm,
                  isLoading: _isLoading,
                  color: const Color(0xFFf39c12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFf39c12).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildRouteRow('📍 From', _startAddress ?? 'Unknown'),
          const SizedBox(height: 8),
          const Icon(Icons.arrow_downward, color: Color(0xFFf39c12)),
          const SizedBox(height: 8),
          _buildRouteRow('📍 To', _endAddress ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildRouteRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFf39c12).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select Date',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _modes.map((mode) {
        final isSelected = _modeOfTravel == mode['value'];
        return InkWell(
          onTap: () => setState(() => _modeOfTravel = mode['value']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFf39c12).withOpacity(0.2)
                  : const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFf39c12)
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Text(
              mode['label'],
              style: TextStyle(
                color: isSelected ? const Color(0xFFf39c12) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurposeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _purposes.map((purpose) {
        final isSelected = _tripPurpose == purpose['value'];
        return InkWell(
          onTap: () => setState(() => _tripPurpose = purpose['value']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFf39c12).withOpacity(0.2)
                  : const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFf39c12)
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Text(
              purpose['label']!,
              style: TextStyle(
                color: isSelected ? const Color(0xFFf39c12) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompanionSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFf39c12).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '👥 Number of Companions',
            style: TextStyle(color: Colors.white),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_companions > 0) {
                    setState(() => _companions--);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFFf39c12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf39c12).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _companions.toString(),
                  style: const TextStyle(
                    color: Color(0xFFf39c12),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _companions++),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFFf39c12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<LatLng> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return const LatLng(28.6139, 77.2090);
    }
  }

  void _onMapTap(LatLng position) async {
    if (_startPoint == null) {
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _startPoint = position;
        _startAddress = address;
        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        );
      });
    } else if (_endPoint == null) {
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _endPoint = position;
        _endAddress = address;
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
      });

      // Adjust camera
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _startPoint!.latitude < position.latitude
                  ? _startPoint!.latitude
                  : position.latitude,
              _startPoint!.longitude < position.longitude
                  ? _startPoint!.longitude
                  : position.longitude,
            ),
            northeast: LatLng(
              _startPoint!.latitude > position.latitude
                  ? _startPoint!.latitude
                  : position.latitude,
              _startPoint!.longitude > position.longitude
                  ? _startPoint!.longitude
                  : position.longitude,
            ),
          ),
          100,
        ),
      );
    } else {
      // Reset
      setState(() {
        _startPoint = null;
        _endPoint = null;
        _startAddress = null;
        _endAddress = null;
        _markers.clear();
      });
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFf39c12),
              surface: Color(0xFF16213e),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 1)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFf39c12),
              surface: Color(0xFF16213e),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (_startPoint == null || _endPoint == null) {
      _showError('Please select route locations');
      return;
    }

    if (_tripNameController.text.isEmpty || _modeOfTravel == null || _tripPurpose == null) {
      _showError('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();

      final body = {
        'trip_name': _tripNameController.text,
        'start_latitude': _startPoint!.latitude,
        'start_longitude': _startPoint!.longitude,
        'end_latitude': _endPoint!.latitude,
        'end_longitude': _endPoint!.longitude,
        'start_location': _startAddress,
        'end_location': _endAddress,
        'start_date': _startDate.toIso8601String().split('T')[0],
        'mode_of_travel': _modeOfTravel,
        'trip_purpose': _tripPurpose,
        'number_of_companions': _companions,
      };

      if (_descriptionController.text.isNotEmpty) {
        body['description'] = _descriptionController.text;
      }
      if (_endDate != null) {
        body['end_date'] = _endDate!.toIso8601String().split('T')[0];
      }
      if (_budgetController.text.isNotEmpty) {
        final budget = double.tryParse(_budgetController.text);
        if (budget != null) body['estimated_budget'] = budget;
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/trips/create-planned/'),
        headers: api.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip planned successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to save planned trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}