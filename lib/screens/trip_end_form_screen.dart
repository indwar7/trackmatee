import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import 'onboarding/home_screen.dart';

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

  // Form controllers
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
  final _parkingController = TextEditingController();
  final _tollController = TextEditingController();
  final _ticketController = TextEditingController();
  final _totalCostController = TextEditingController();

  // CO2 emission factors
  final Map<String, double> _co2EmissionFactors = {
    'Car - Petrol': 0.192,
    'Car - Diesel': 0.171,
    'Car - CNG': 0.157,
    'Car - Electric': 0.053,
    'Motorcycle': 0.103,
    'Bus': 0.089,
    'Train': 0.041,
    'Metro': 0.033,
    'Auto Rickshaw': 0.085,
    'Bicycle': 0.0,
    'Walking': 0.0,
    'Other': 0.15,
  };

  /// NEW: Backend accepted values mapping
  final Map<String, String> _modeBackendMap = {
    'Car - Petrol': 'car_petrol',
    'Car - Diesel': 'car_diesel',
    'Car - CNG': 'car_cng',
    'Car - Electric': 'car_electric',
    'Motorcycle': 'motorcycle',
    'Bus': 'bus',
    'Train': 'train',
    'Metro': 'metro',
    'Auto Rickshaw': 'auto',
    'Bicycle': 'bicycle',
    'Walking': 'walking',
    'Other': 'other',
  };

  @override
  void initState() {
    super.initState();
    _selectedEndPoint = LatLng(widget.endLat, widget.endLng);
    _selectedEndAddress = widget.endLocation;

    _startLocationController.text = widget.startLocation;
    _endLocationController.text = widget.endLocation;
    _distanceController.text = widget.distance.toStringAsFixed(2);
    _durationController.text = widget.duration.toString();

    final now = DateTime.now();
    _dateController.text = '${now.day}/${now.month}/${now.year}';
    _timeController.text = '${now.hour}:${now.minute}';

    _modeController.text = 'Car - Petrol';
    _calculateCO2Emission();

    _addEndMarker();

    _fuelCostController.addListener(_calculateTotalCost);
    _parkingController.addListener(_calculateTotalCost);
    _tollController.addListener(_calculateTotalCost);
    _ticketController.addListener(_calculateTotalCost);

    _modeController.addListener(_calculateCO2Emission);
    _distanceController.addListener(_calculateCO2Emission);
  }

  void _calculateCO2Emission() {
    final mode = _modeController.text;
    final distance = double.tryParse(_distanceController.text) ?? 0.0;

    final emissionFactor = _co2EmissionFactors[mode] ?? 0.15;
    final co2 = distance * emissionFactor;

    setState(() {
      _co2Controller.text = co2.toStringAsFixed(2);
    });
  }

  void _calculateTotalCost() {
    final fuelCost = double.tryParse(_fuelCostController.text) ?? 0.0;
    final parkingCost = double.tryParse(_parkingController.text) ?? 0.0;
    final tollCost = double.tryParse(_tollController.text) ?? 0.0;
    final ticketCost = double.tryParse(_ticketController.text) ?? 0.0;

    setState(() {
      _totalCostController.text =
          (fuelCost + parkingCost + tollCost + ticketCost).toStringAsFixed(2);
    });
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
    _parkingController.dispose();
    _tollController.dispose();
    _ticketController.dispose();
    _totalCostController.dispose();
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
            child: const Text(
              'Tap on map to adjust END location',
              style: TextStyle(color: Colors.white),
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
            child: const Text('Continue', style: TextStyle(fontSize: 18, color: Colors.white)),
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
            _buildFormField('Start Location', _startLocationController, Icons.trip_origin, readOnly: true),
            _buildFormField('End Location', _endLocationController, Icons.location_on, readOnly: true),
            _buildFormField('Day/Time', _dateController, Icons.calendar_today, onTap: () => _selectDate(context)),
            _buildFormField('Duration (minutes)', _durationController, Icons.timer, keyboardType: TextInputType.number),
            _buildFormField('Distance (km)', _distanceController, Icons.straighten, keyboardType: TextInputType.number),

            _buildModeDropdown(),

            _buildFormField(
              'CO2 emitted (kg)',
              _co2Controller,
              Icons.cloud,
              readOnly: true,
              fillColor: const Color(0xFF1a2942),
            ),

            _buildFormField('Trip purpose', _purposeController, Icons.work),
            _buildFormField('Number of companions', _companionsController, Icons.people, keyboardType: TextInputType.number),
            _buildFormField('Fuel Type', _fuelTypeController, Icons.local_gas_station),
            _buildFormField('Fuel cost (₹)', _fuelCostController, Icons.attach_money, keyboardType: TextInputType.number),
            _buildFormField('Parking cost (₹)', _parkingController, Icons.local_parking, keyboardType: TextInputType.number),
            _buildFormField('Toll cost (₹)', _tollController, Icons.toll, keyboardType: TextInputType.number),
            _buildFormField('Ticket cost (₹)', _ticketController, Icons.confirmation_number, keyboardType: TextInputType.number),

            _buildFormField(
              'Total Cost (₹)',
              _totalCostController,
              Icons.account_balance_wallet,
              readOnly: true,
              fillColor: const Color(0xFF1a2942),
            ),

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
                        : const Text('Complete Trip', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _modeController.text,
        dropdownColor: const Color(0xFF16213e),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Mode of Travel',
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.directions_car, color: Color(0xFF00adb5)),
          filled: true,
          fillColor: const Color(0xFF16213e),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: _co2EmissionFactors.keys.map((String mode) {
          return DropdownMenuItem<String>(
            value: mode,
            child: Text(mode),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _modeController.text = newValue ?? '';
          });
        },
      ),
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller,
      IconData? icon, {
        TextInputType? keyboardType,
        VoidCallback? onTap,
        bool readOnly = false,
        Color? fillColor,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly || onTap != null,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF00adb5)) : null,
          filled: true,
          fillColor: fillColor ?? const Color(0xFF16213e),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        _dateController.text =
        '${picked.day}/${picked.month}/${picked.year} ${time.hour}:${time.minute}';
      }
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();

      final fuelCost = double.tryParse(_fuelCostController.text);
      final parkingCost = double.tryParse(_parkingController.text);
      final tollCost = double.tryParse(_tollController.text);
      final ticketCost = double.tryParse(_ticketController.text);
      final companions = int.tryParse(_companionsController.text);

      await api.endTrip(
        tripId: widget.tripId,
        endLat: _selectedEndPoint!.latitude,
        endLng: _selectedEndPoint!.longitude,
        endLocationName: _selectedEndAddress,
        modeOfTravel: _modeBackendMap[_modeController.text], // FIXED HERE
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
          MaterialPageRoute(builder: (_) => HomeScreen()),
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