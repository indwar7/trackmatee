import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'home_screen.dart';

class TripEndFormScreen extends StatefulWidget {
  final int tripId;
  final String startLocation;
  final double endLat;
  final double endLng;
  final String endLocation;
  final double distance;
  final int duration;

  const TripEndFormScreen({
    super.key,
    required this.tripId,
    required this.startLocation,
    required this.endLat,
    required this.endLng,
    required this.endLocation,
    required this.distance,
    required this.duration,
  });

  @override
  State<TripEndFormScreen> createState() => _TripEndFormScreenState();
}

class _TripEndFormScreenState extends State<TripEndFormScreen> {
  GoogleMapController? _mapController;

  LatLng? _selectedEndPoint;
  String? _selectedEndAddress;
  final Set<Marker> _markers = {};

  bool _showForm = false;
  bool _isLoading = false;

  // Form controllers - EXACTLY matching manual trip fields
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _co2Controller = TextEditingController();
  final _modeController = TextEditingController();
  final _purposeController = TextEditingController();
  final _companionsController = TextEditingController(text: '0');
  final _fuelTypeController = TextEditingController();
  final _fuelCostController = TextEditingController();
  final _averageController = TextEditingController();
  final _parkingController = TextEditingController();
  final _tollController = TextEditingController();
  final _ticketController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedEndPoint = LatLng(widget.endLat, widget.endLng);
    _selectedEndAddress = widget.endLocation;

    // Pre-fill data
    _startLocationController.text = widget.startLocation;
    _endLocationController.text = widget.endLocation;
    _distanceController.text = widget.distance.toStringAsFixed(2);
    _durationController.text = widget.duration.toString();

    // Set current date and time
    final now = DateTime.now();
    _dateController.text = '${now.day}/${now.month}/${now.year}';
    _timeController.text = '${now.hour}:${now.minute}';

    _addEndMarker();
  }

  void _addEndMarker() {
    if (_selectedEndPoint != null) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: _selectedEndPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'End Location'),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _startLocationController.dispose();
    _endLocationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        title: const Text('Trip Info'),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213e),
        automaticallyImplyLeading: false,
      ),
      body: _showForm ? _buildForm() : _buildMapView(),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _selectedEndPoint!,
            zoom: 15,
          ),
          onMapCreated: (controller) => _mapController = controller,
          onTap: _onMapTap,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),

        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Tap on map to adjust END location',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: ElevatedButton(
            onPressed: () => setState(() => _showForm = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00adb5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  void _onMapTap(LatLng position) async {
    final address = await LocationService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _selectedEndPoint = position;
      _selectedEndAddress = address;
      _endLocationController.text = address;
    });

    _addEndMarker();
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  Widget _buildForm() {
    return Container(
      color: const Color(0xFF0f0f1e),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormField('Start Location', _startLocationController, Icons.trip_origin),
            _buildFormField('End Location', _endLocationController, Icons.location_on),
            _buildFormField('Day/Time', _dateController, Icons.calendar_today, onTap: () => _selectDate(context)),
            _buildFormField('Duration (minutes)', _durationController, Icons.timer, keyboardType: TextInputType.number),
            _buildFormField('Distance (km)', _distanceController, Icons.straighten, keyboardType: TextInputType.number),
            _buildFormField('CO2 emitted (kg)', _co2Controller, Icons.cloud, keyboardType: TextInputType.number),
            _buildFormField('Mode of Travel', _modeController, Icons.directions_car),
            _buildFormField('Trip purpose', _purposeController, Icons.work),
            _buildFormField('Number of companions', _companionsController, Icons.people, keyboardType: TextInputType.number),
            _buildFormField('Fuel Type', _fuelTypeController, Icons.local_gas_station),
            _buildFormField('Fuel cost', _fuelCostController, Icons.attach_money, keyboardType: TextInputType.number),
            _buildFormField('Average of the vehicle', _averageController, Icons.speed, keyboardType: TextInputType.number),
            _buildFormField('Parking cost', _parkingController, Icons.local_parking, keyboardType: TextInputType.number),
            _buildFormField('Toll cost', _tollController, Icons.toll, keyboardType: TextInputType.number),
            _buildFormField('Ticket cost', _ticketController, Icons.confirmation_number, keyboardType: TextInputType.number),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showForm = false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF00adb5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Map', style: TextStyle(color: Color(0xFF00adb5))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00adb5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Complete Trip', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller,
      IconData? icon, {
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
      final TimeOfDay? time = await showTimePicker(
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
      if (time != null) {
        _dateController.text = '${picked.day}/${picked.month}/${picked.year} ${time.hour}:${time.minute}';
      }
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();

      final fuelCost = _fuelCostController.text.isNotEmpty
          ? double.tryParse(_fuelCostController.text)
          : null;
      final parkingCost = _parkingController.text.isNotEmpty
          ? double.tryParse(_parkingController.text)
          : null;
      final tollCost = _tollController.text.isNotEmpty
          ? double.tryParse(_tollController.text)
          : null;
      final ticketCost = _ticketController.text.isNotEmpty
          ? double.tryParse(_ticketController.text)
          : null;
      final companions = _companionsController.text.isNotEmpty
          ? int.tryParse(_companionsController.text)
          : null;

      await api.endTrip(
        tripId: widget.tripId,
        endLat: _selectedEndPoint!.latitude,
        endLng: _selectedEndPoint!.longitude,
        endLocationName: _selectedEndAddress,
        modeOfTravel: _modeController.text.isNotEmpty ? _modeController.text : null,
        tripPurpose: _purposeController.text.isNotEmpty ? _purposeController.text : null,
        companions: companions,
        fuelExpense: fuelCost,
        parkingCost: parkingCost,
        tollCost: tollCost,
        ticketCost: ticketCost,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      _showError('Failed to complete trip: $e');
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