import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
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

  final Set<Marker> _markers = {};
  bool _showForm = false;

  // Form fields
  final _tripNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();

  String? _modeOfTravel;
  String? _tripPurpose;
  int _companions = 0;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate;

  bool _isLoading = false;
  List<PlaceSuggestion> _startSuggestions = [];
  List<PlaceSuggestion> _endSuggestions = [];
  bool _showStartSuggestions = false;
  bool _showEndSuggestions = false;

  // Add your Google Maps API key here
  static const String _googleApiKey = 'AIzaSyA6uK1raTG6fNpw5twxbX0tfveW6Rd5YNE';

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
    _startLocationController.dispose();
    _endLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan a Trip'),
        centerTitle: true,
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Location Input Section
          _buildLocationInputSection(),
          const SizedBox(height: 24),

          // Show map preview if both locations are selected
          if (_startPoint != null && _endPoint != null) ...[
            _buildMapPreview(),
            const SizedBox(height: 24),
          ],

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

          // Submit Button
          CustomButton(
            text: 'Save Plan',
            onPressed: _submitForm,
            isLoading: _isLoading,
            color: const Color(0xFFf39c12),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Route Details *'),
        const SizedBox(height: 12),

        // Start Location Input
        _buildLocationTextField(
          controller: _startLocationController,
          label: 'Start Location',
          icon: Icons.location_on,
          iconColor: Colors.green,
          onChanged: (value) {
            _onStartLocationChanged(value);
            setState(() {});
          },
          onTap: () => setState(() => _showStartSuggestions = true),
        ),

        // Start Location Suggestions
        if (_showStartSuggestions && _startSuggestions.isNotEmpty)
          _buildSuggestionsList(_startSuggestions, true),

        const SizedBox(height: 16),

        // End Location Input
        _buildLocationTextField(
          controller: _endLocationController,
          label: 'Destination',
          icon: Icons.location_on,
          iconColor: Colors.orange,
          onChanged: (value) {
            _onEndLocationChanged(value);
            setState(() {});
          },
          onTap: () => setState(() => _showEndSuggestions = true),
        ),

        // End Location Suggestions
        if (_showEndSuggestions && _endSuggestions.isNotEmpty)
          _buildSuggestionsList(_endSuggestions, false),

        const SizedBox(height: 12),

        // Use Current Location Button
        TextButton.icon(
          onPressed: _useCurrentLocation,
          icon: const Icon(Icons.my_location, color: Color(0xFFf39c12)),
          label: const Text(
            'Use current location as start',
            style: TextStyle(color: Color(0xFFf39c12)),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Function(String) onChanged,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: 'Enter location...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: iconColor),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.white54),
          onPressed: () {
            controller.clear();
            if (label.contains('Start')) {
              setState(() {
                _startPoint = null;
                _startAddress = null;
                _startSuggestions.clear();
                _showStartSuggestions = false;
                _updateMarkers();
              });
            } else {
              setState(() {
                _endPoint = null;
                _endAddress = null;
                _endSuggestions.clear();
                _showEndSuggestions = false;
                _updateMarkers();
              });
            }
          },
        )
            : null,
        filled: true,
        fillColor: const Color(0xFF16213e),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<PlaceSuggestion> suggestions, bool isStart) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.white.withOpacity(0.1),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_on, color: Color(0xFFf39c12)),
            title: Text(
              suggestion.mainText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              suggestion.secondaryText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            onTap: () => _selectPlace(suggestion, isStart),
          );
        },
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFf39c12).withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _startPoint!,
            zoom: 12,
          ),
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
            _adjustCameraToMarkers();
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
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

  // Location Search Functions
  Future<void> _onStartLocationChanged(String value) async {
    if (value.length < 3) {
      setState(() {
        _startSuggestions.clear();
        _showStartSuggestions = false;
      });
      return;
    }

    final suggestions = await _fetchPlaceSuggestions(value);
    setState(() {
      _startSuggestions = suggestions;
      _showStartSuggestions = true;
    });
  }

  Future<void> _onEndLocationChanged(String value) async {
    if (value.length < 3) {
      setState(() {
        _endSuggestions.clear();
        _showEndSuggestions = false;
      });
      return;
    }

    final suggestions = await _fetchPlaceSuggestions(value);
    setState(() {
      _endSuggestions = suggestions;
      _showEndSuggestions = true;
    });
  }

  Future<List<PlaceSuggestion>> _fetchPlaceSuggestions(String input) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=$input'
            '&key=$_googleApiKey'
            '&components=country:in', // Restrict to India, remove if not needed
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = data['predictions'] as List;

        return predictions.map((pred) {
          return PlaceSuggestion(
            placeId: pred['place_id'],
            mainText: pred['structured_formatting']['main_text'],
            secondaryText: pred['structured_formatting']['secondary_text'] ?? '',
            description: pred['description'],
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
    return [];
  }

  Future<void> _selectPlace(PlaceSuggestion suggestion, bool isStart) async {
    try {
      // Get place details to fetch coordinates
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=${suggestion.placeId}'
            '&fields=geometry'
            '&key=$_googleApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Add this debug print
        print('Place details response: $data');

        final location = data['result']['geometry']['location'];
        final latLng = LatLng(location['lat'], location['lng']);

        if (mounted) {  // ADD THIS CHECK
          setState(() {
            if (isStart) {
              _startPoint = latLng;
              _startAddress = suggestion.description;
              _startLocationController.text = suggestion.description;
              _startSuggestions.clear();
              _showStartSuggestions = false;
            } else {
              _endPoint = latLng;
              _endAddress = suggestion.description;
              _endLocationController.text = suggestion.description;
              _endSuggestions.clear();
              _showEndSuggestions = false;
            }
            _updateMarkers();
          });

          // Add this debug print
          print('Start Point: $_startPoint, End Point: $_endPoint');
        }
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error selecting place: $e');
      if (mounted) {
        _showError('Failed to get location details');
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final latLng = LatLng(position.latitude, position.longitude);
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {  // ADD THIS CHECK
        setState(() {
          _startPoint = latLng;
          _startAddress = address;
          _startLocationController.text = address;
          _updateMarkers();
        });

        // Add this debug print
        print('Current location set: $_startPoint');
      }
    } catch (e) {
      print('Error getting current location: $e');
      if (mounted) {
        _showError('Failed to get current location: $e');
      }
    }
  }

  void _updateMarkers() {
    _markers.clear();

    if (_startPoint != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _startPoint!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Start', snippet: _startAddress),
        ),
      );
    }

    if (_endPoint != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _endPoint!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: 'Destination', snippet: _endAddress),
        ),
      );
    }

    if (_startPoint != null && _endPoint != null) {
      _adjustCameraToMarkers();
    }
  }

  void _adjustCameraToMarkers() {
    if (_startPoint != null && _endPoint != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _startPoint!.latitude < _endPoint!.latitude
                  ? _startPoint!.latitude
                  : _endPoint!.latitude,
              _startPoint!.longitude < _endPoint!.longitude
                  ? _startPoint!.longitude
                  : _endPoint!.longitude,
            ),
            northeast: LatLng(
              _startPoint!.latitude > _endPoint!.latitude
                  ? _startPoint!.latitude
                  : _endPoint!.latitude,
              _startPoint!.longitude > _endPoint!.longitude
                  ? _startPoint!.longitude
                  : _endPoint!.longitude,
            ),
          ),
          50,
        ),
      );
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
      _showError('Please select start and destination locations');
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

      print('Sending request to: ${ApiService.baseUrl}/trips/create-planned/');
      print('Request body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/trips/create-planned/'),
        headers: {
          ...api.headers,
          'Content-Type': 'application/json',  // Make sure this is set
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          // Navigate to saved trips screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SavedPlannedTripsScreen(),
            ),
          );

          // Show success message
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

// Model class for place suggestions
class PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });
}