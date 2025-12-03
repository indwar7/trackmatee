import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

class ManualTripScreen extends StatefulWidget {
  const ManualTripScreen({super.key});

  @override
  State<ManualTripScreen> createState() => _ManualTripScreenState();
}

class _ManualTripScreenState extends State<ManualTripScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.6139, 77.2090); // Default Delhi

  // Location markers
  LatLng? _startLocation;
  LatLng? _endLocation;

  // Text controllers
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  // Form display
  bool _showForm = false;

  // Form controllers
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _co2Controller = TextEditingController();
  final _modeController = TextEditingController(text: 'Car');
  final _purposeController = TextEditingController();
  final _companionsController = TextEditingController(text: '0');
  final _fuelTypeController = TextEditingController(text: 'Petrol');
  final _fuelCostController = TextEditingController();
  final _averageController = TextEditingController();
  final _parkingController = TextEditingController();
  final _tollController = TextEditingController();
  final _ticketController = TextEditingController();

  bool _isLoading = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool hasPermission = await LocationService.checkPermissions();
      if (!hasPermission) return;

      Position position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 14),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _onMapTap(LatLng position) async {
    if (_startLocation == null) {
      // Set start location
      setState(() {
        _startLocation = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        );
      });

      // Get address for start location
      String address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      _startController.text = address;

    } else if (_endLocation == null) {
      // Set end location
      setState(() {
        _endLocation = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'End'),
          ),
        );
      });

      // Get address for end location
      String address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      _endController.text = address;

      // Draw route line
      _drawRoute();

      // Show the form
      setState(() {
        _showForm = true;
      });
    }
  }

  void _drawRoute() {
    if (_startLocation != null && _endLocation != null) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [_startLocation!, _endLocation!],
            color: const Color(0xFF00adb5),
            width: 4,
          ),
        );
      });

      // Calculate distance
      double distanceInMeters = Geolocator.distanceBetween(
        _startLocation!.latitude,
        _startLocation!.longitude,
        _endLocation!.latitude,
        _endLocation!.longitude,
      );

      _distanceController.text = (distanceInMeters / 1000).toStringAsFixed(2);
    }
  }

  void _resetLocations() {
    setState(() {
      _startLocation = null;
      _endLocation = null;
      _markers.clear();
      _polylines.clear();
      _startController.clear();
      _endController.clear();
      _showForm = false;
    });
  }

  Future<void> _saveTrip() async {
    if (_startLocation == null || _endLocation == null) {
      _showError('Please select both start and end locations');
      return;
    }

    if (_dateController.text.isEmpty || _modeController.text.isEmpty) {
      _showError('Please fill required fields (Date, Mode)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();

      final body = {
        'start_latitude': _startLocation!.latitude,
        'start_longitude': _startLocation!.longitude,
        'end_latitude': _endLocation!.latitude,
        'end_longitude': _endLocation!.longitude,
        'start_location': _startController.text,
        'end_location': _endController.text,
        'trip_date': _dateController.text,
        'mode_of_travel': _modeController.text.toLowerCase(),
      };

      if (_purposeController.text.isNotEmpty) {
        body['trip_purpose'] = _purposeController.text.toLowerCase();
      }
      if (_companionsController.text.isNotEmpty) {
        final companions = int.tryParse(_companionsController.text);
        if (companions != null) body['number_of_companions'] = companions;
      }
      if (_fuelCostController.text.isNotEmpty) {
        final fuelCost = double.tryParse(_fuelCostController.text);
        if (fuelCost != null) body['fuel_expense'] = fuelCost;
      }
      if (_parkingController.text.isNotEmpty) {
        final parkingCost = double.tryParse(_parkingController.text);
        if (parkingCost != null) body['parking_cost'] = parkingCost;
      }
      if (_tollController.text.isNotEmpty) {
        final tollCost = double.tryParse(_tollController.text);
        if (tollCost != null) body['toll_cost'] = tollCost;
      }
      if (_ticketController.text.isNotEmpty) {
        final ticketCost = double.tryParse(_ticketController.text);
        if (ticketCost != null) body['ticket_cost'] = ticketCost;
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/trips/create-manual/'),
        headers: api.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to save trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        title: const Text('Save Untracked Trip'),
        backgroundColor: const Color(0xFF16213e),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetLocations,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: _showForm ? 2 : 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: _onMapTap,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                ),

                // Instructions overlay
                if (!_showForm)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _startLocation == null
                            ? 'Tap on map to select START location'
                            : 'Tap on map to select END location',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Location Display
          Container(
            color: const Color(0xFF16213e),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLocationField(
                  icon: Icons.trip_origin,
                  label: 'Start Location',
                  controller: _startController,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                _buildLocationField(
                  icon: Icons.location_on,
                  label: 'End Location',
                  controller: _endController,
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // Form Section
          if (_showForm)
            Expanded(
              flex: 3,
              child: Container(
                color: const Color(0xFF0f0f1e),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFormField('Date', _dateController,
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                      ),
                      _buildFormField('Time', _timeController,
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context),
                      ),
                      _buildFormField('Duration (mins)', _durationController,
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                      ),
                      _buildFormField('Distance (km)', _distanceController,
                        icon: Icons.straighten,
                        keyboardType: TextInputType.number,
                      ),
                      _buildFormField('CO2 Emitted (kg)', _co2Controller,
                        icon: Icons.cloud,
                        keyboardType: TextInputType.number,
                      ),
                      _buildFormField('Mode of Travel', _modeController,
                        icon: Icons.directions_car,
                      ),
                      _buildFormField('Trip Purpose', _purposeController,
                        icon: Icons.description,
                      ),
                      _buildFormField('Number of Companions', _companionsController,
                        icon: Icons.people,
                        keyboardType: TextInputType.number,
                      ),
                      _buildFormField('Fuel Type', _fuelTypeController,
                        icon: Icons.local_gas_station,
                      ),
                      _buildFormField('Fuel Cost', _fuelCostController,
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      _buildFormField('Average (km/l)', _averageController,
                        icon: Icons.speed,
                        keyboardType: TextInputType.number,
                      ),
                      _buildFormField('Parking Cost', _parkingController,
                        icon: Icons.local_parking,
                        keyboardType: TextInputType.number,
                      ),
                      _buildFormField('Toll Cost', _tollController,
                        icon: Icons.toll,
                        keyboardType: TextInputType.number,
                      ),
                      _buildFormField('Ticket Cost', _ticketController,
                        icon: Icons.confirmation_number,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00adb5),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Save Trip',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f1e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              controller.text.isEmpty ? label : controller.text,
              style: TextStyle(
                color: controller.text.isEmpty
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller, {
        IconData? icon,
        TextInputType? keyboardType,
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: onTap != null,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF00adb5)) : null,
          filled: true,
          fillColor: const Color(0xFF16213e),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00adb5)),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00adb5),
              surface: Color(0xFF16213e),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00adb5),
              surface: Color(0xFF16213e),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _timeController.text = picked.format(context);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _startController.dispose();
    _endController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _distanceController.dispose();
    _co2Controller.dispose();
    _modeController.dispose();
    _purposeController.dispose();
    _companionsController.dispose();
    _fuelTypeController.dispose();
    _fuelCostController.dispose();
    _averageController.dispose();
    _parkingController.dispose();
    _tollController.dispose();
    _ticketController.dispose();
    super.dispose();
  }
}