import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../widgets/location_search_widget.dart';

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

  // Search state
  bool _isSearchingStart = false;
  bool _isSearchingEnd = false;
  List<dynamic> _startSuggestions = [];
  List<dynamic> _endSuggestions = [];

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
  final _parkingController = TextEditingController();
  final _tollController = TextEditingController();
  final _ticketController = TextEditingController();
  final _totalCostController = TextEditingController();

  bool _isLoading = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _testConnection();
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

  Future<void> _searchStartLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _startSuggestions = [];
        _isSearchingStart = false;
      });
      return;
    }

    setState(() => _isSearchingStart = true);

    try {
      final suggestions = await LocationService.searchLocation(query);
      setState(() {
        _startSuggestions = suggestions;
        _isSearchingStart = false;
      });
    } catch (e) {
      setState(() => _isSearchingStart = false);
      debugPrint('Error searching location: $e');
    }
  }

  Future<void> _searchEndLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _endSuggestions = [];
        _isSearchingEnd = false;
      });
      return;
    }

    setState(() => _isSearchingEnd = true);

    try {
      final suggestions = await LocationService.searchLocation(query);
      setState(() {
        _endSuggestions = suggestions;
        _isSearchingEnd = false;
      });
    } catch (e) {
      setState(() => _isSearchingEnd = false);
      debugPrint('Error searching location: $e');
    }
  }

  void _selectStartLocation(dynamic place) {
    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];
    final address = place['formatted_address'] ?? place['description'];

    setState(() {
      _startLocation = LatLng(lat, lng);
      _startController.text = address;
      _startSuggestions = [];

      _markers.removeWhere((m) => m.markerId.value == 'start');
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _startLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Start'),
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_startLocation!, 14),
    );

    if (_endLocation != null) {
      _drawRoute();
      setState(() => _showForm = true);
    }
  }

  void _selectEndLocation(dynamic place) {
    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];
    final address = place['formatted_address'] ?? place['description'];

    setState(() {
      _endLocation = LatLng(lat, lng);
      _endController.text = address;
      _endSuggestions = [];

      _markers.removeWhere((m) => m.markerId.value == 'end');
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _endLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'End'),
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_endLocation!, 14),
    );

    if (_startLocation != null) {
      _drawRoute();
      setState(() => _showForm = true);
    }
  }

  double _calculateCO2() {
    if (_distanceController.text.isEmpty || _modeController.text.isEmpty) {
      return 0;
    }

    final distance = double.tryParse(_distanceController.text) ?? 0;
    final mode = _modeController.text.toLowerCase();

    // CO2 emission factors (kg CO2 per km)
    const Map<String, double> emissionFactors = {
      'car': 0.21,
      'bike': 0.0,
      'bus': 0.089,
      'train': 0.041,
      'walk': 0.0,
      'metro': 0.028,
      'auto': 0.15,
    };

    final factor = emissionFactors[mode] ?? 0.21;
    return distance * factor;
  }

  void _updateCO2() {
    final co2 = _calculateCO2();
    _co2Controller.text = co2.toStringAsFixed(2);
  }

  void _calculateTotalCost() {
    double total = 0;

    if (_fuelCostController.text.isNotEmpty) {
      total += double.tryParse(_fuelCostController.text) ?? 0;
    }
    if (_parkingController.text.isNotEmpty) {
      total += double.tryParse(_parkingController.text) ?? 0;
    }
    if (_tollController.text.isNotEmpty) {
      total += double.tryParse(_tollController.text) ?? 0;
    }
    if (_ticketController.text.isNotEmpty) {
      total += double.tryParse(_ticketController.text) ?? 0;
    }

    _totalCostController.text = total.toStringAsFixed(2);
  }
  Future<void> _testConnection() async {
    try {
      final api = context.read<ApiService>();
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/trips/'),
        headers: api.headers,
      );
      print('✅ Connection test: ${response.statusCode}');
      print('Response: ${response.body}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection successful! Status: ${response.statusCode}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Connection failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
      _updateCO2();
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
      _startSuggestions = [];
      _endSuggestions = [];
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
            icon: const Icon(Icons.wifi),
            onPressed: _testConnection,
            tooltip: 'Test Connection',
          ),
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
                            ? 'Tap on map to select START location or type below'
                            : 'Tap on map to select END location or type below',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Location Display with Search
          Container(
            color: const Color(0xFF16213e),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Start Location Search
                _buildSearchableLocationField(
                  icon: Icons.trip_origin,
                  label: 'Start Location',
                  controller: _startController,
                  color: Colors.green,
                  suggestions: _startSuggestions,
                  isSearching: _isSearchingStart,
                  onChanged: _searchStartLocation,
                  onSuggestionSelected: _selectStartLocation,
                ),
                const SizedBox(height: 8),
                // End Location Search
                _buildSearchableLocationField(
                  icon: Icons.location_on,
                  label: 'End Location',
                  controller: _endController,
                  color: Colors.red,
                  suggestions: _endSuggestions,
                  isSearching: _isSearchingEnd,
                  onChanged: _searchEndLocation,
                  onSuggestionSelected: _selectEndLocation,
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
                        onChanged: (value) => _updateCO2(),
                      ),
                      _buildFormField('CO2 Emitted (kg)', _co2Controller,
                        icon: Icons.cloud,
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                      _buildFormField('Mode of Travel', _modeController,
                        icon: Icons.directions_car,
                        onChanged: (value) => _updateCO2(),
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
                        onChanged: (value) => _calculateTotalCost(),
                      ),
                      _buildFormField('Parking Cost', _parkingController,
                        icon: Icons.local_parking,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _calculateTotalCost(),
                      ),
                      _buildFormField('Toll Cost', _tollController,
                        icon: Icons.toll,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _calculateTotalCost(),
                      ),
                      _buildFormField('Ticket Cost', _ticketController,
                        icon: Icons.confirmation_number,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _calculateTotalCost(),
                      ),
                      _buildFormField('Total Cost', _totalCostController,
                        icon: Icons.account_balance_wallet,
                        keyboardType: TextInputType.number,
                        readOnly: true,
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

  Widget _buildSearchableLocationField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Color color,
    required List<dynamic> suggestions,
    required bool isSearching,
    required Function(String) onChanged,
    required Function(dynamic) onSuggestionSelected,
  }) {
    return Column(
      children: [
        Container(
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
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: label,
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (isSearching)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF00adb5),
                  ),
                ),
            ],
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00adb5).withOpacity(0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: suggestions.length > 5 ? 5 : suggestions.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withOpacity(0.1),
                  height: 1,
                  thickness: 0.5,
                ),
                itemBuilder: (context, index) {
                  final place = suggestions[index];
                  final String placeDescription = place['description'] ??
                      place['formatted_address'] ??
                      'Unknown location';

                  return InkWell(
                    onTap: () => onSuggestionSelected(place),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: color,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              placeDescription,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller, {
        IconData? icon,
        TextInputType? keyboardType,
        VoidCallback? onTap,
        Function(String)? onChanged,
        bool readOnly = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly || onTap != null,
        onTap: onTap,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF00adb5)) : null,
          filled: true,
          fillColor: readOnly ? const Color(0xFF16213e).withOpacity(0.5) : const Color(0xFF16213e),
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
    _parkingController.dispose();
    _tollController.dispose();
    _ticketController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }
}