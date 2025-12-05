import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import 'saved_planned_trips_screen.dart';

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

  final _tripNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();

  final Set<Marker> _markers = {};

  String? _modeOfTravel;
  String? _tripPurpose;
  int _companions = 0;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate;

  bool _isLoading = false;

  static const String _googleApiKey = "AIzaSyA6uK1raTG6fNpw5twxbX0tfveW6Rd5YNE";

  final List<Map<String, dynamic>> _modes = [
    {"value": "car", "label": "🚗 Car"},
    {"value": "bike", "label": "🏍 Bike"},
    {"value": "bus", "label": "🚌 Bus"},
    {"value": "train", "label": "🚂 Train"},
    {"value": "metro", "label": "🚇 Metro"},
    {"value": "walk", "label": "🚶 Walk"},
  ];

  final List<Map<String, String>> _purposes = [
    {"value": "work", "label": "💼 Work"},
    {"value": "education", "label": "📚 Education"},
    {"value": "shopping", "label": "🛍 Shopping"},
    {"value": "social", "label": "🎉 Social"},
    {"value": "medical", "label": "🏥 Medical"},
    {"value": "personal", "label": "📋 Personal"},
    {"value": "vacation", "label": "🏖 Vacation"},
  ];

  @override
  void dispose() {
    _mapController?.dispose();
    _tripNameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _startLocationController.dispose();
    _endLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("Plan a Trip"),
        backgroundColor: const Color(0xFF0A0A0A),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLocationInputs(),
          const SizedBox(height: 16),
          if (_startPoint != null && _endPoint != null) _buildMapPreview(),
          const SizedBox(height: 16),

          _field(
            controller: _tripNameController,
            label: "Trip Name *",
            icon: Icons.label,
          ),
          const SizedBox(height: 12),

          _field(
            controller: _descriptionController,
            label: "Description",
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          _sectionTitle("Mode of Travel *"),
          const SizedBox(height: 8),
          _optionSelector(_modes, (v) => _modeOfTravel = v),

          const SizedBox(height: 16),
          _sectionTitle("Purpose *"),
          const SizedBox(height: 8),
          _optionSelector(_purposes, (v) => _tripPurpose = v),

          const SizedBox(height: 16),
          _sectionTitle("Budget"),
          const SizedBox(height: 8),
          _field(
            controller: _budgetController,
            label: "Estimated Budget",
            icon: Icons.account_balance_wallet,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 26),

          /// 🚨 FIXED LOADING BUTTON
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf39c12),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ))
                : const Text(
              "Save Trip Plan",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 Reusable input
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFf39c12)),
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF16213e),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
  );

  Widget _optionSelector(List<Map<String, dynamic>> list, Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: list.map((e) {
        final selected = (_modeOfTravel == e["value"] ||
            _tripPurpose == e["value"]);
        return GestureDetector(
          onTap: () => setState(() => onSelect(e["value"])),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFf39c12).withOpacity(0.2)
                  : const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFFf39c12)
                    : Colors.white24,
              ),
            ),
            child: Text(
              e["label"],
              style: TextStyle(
                color: selected
                    ? const Color(0xFFf39c12)
                    : Colors.white70,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationInputs() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle("Locations *"),
      const SizedBox(height: 8),
      _field(
        controller: _startLocationController,
        label: "Start Location",
        icon: Icons.location_on,
      ),
      const SizedBox(height: 10),
      _field(
        controller: _endLocationController,
        label: "Destination",
        icon: Icons.flag,
      ),
    ],
  );

  Widget _buildMapPreview() => Container(
    height: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.black,
    ),
    child: GoogleMap(
      markers: _markers,
      initialCameraPosition: CameraPosition(
        target: _startPoint!,
        zoom: 11,
      ),
      zoomControlsEnabled: false,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) => _mapController = controller,
    ),
  );

  /// 📌 Submit function
  Future<void> _submitForm() async {
    if (_tripNameController.text.isEmpty ||
        _modeOfTravel == null ||
        _tripPurpose == null ||
        _startPoint == null ||
        _endPoint == null) {
      _show("Please fill all required fields");
      return;
    }

    setState(() => _isLoading = true);

    final api = context.read<ApiService>();

    final body = {
      "trip_name": _tripNameController.text,
      "start_latitude": _startPoint!.latitude,
      "start_longitude": _startPoint!.longitude,
      "end_latitude": _endPoint!.latitude,
      "end_longitude": _endPoint!.longitude,
      "mode_of_travel": _modeOfTravel,
      "trip_purpose": _tripPurpose,
      "companions": _companions,
    };

    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/planned-trips/"),
      headers: api.headers,
      body: jsonEncode(body),
    );

    setState(() => _isLoading = false);

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ManualTripEntryScreen(),
        ),
      );
      _show("Trip saved!");
    } else {
      _show("Failed: ${res.body}");
    }
  }

  void _show(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ),
  );
}
