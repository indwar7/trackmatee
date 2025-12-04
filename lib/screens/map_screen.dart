import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../services/location_service.dart';
import 'trip_end_form_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  LatLng? currentLocation;
  LatLng? destinationLocation;
  String? startLocationName;
  String? destinationLocationName;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> travelledPath = [];
  List<LatLng> polylineCoordinates = [];

  final polylinePoints = PolylinePoints();
  final String googleApiKey = "AIzaSyCvuze7W6e4S_5bSAEuX9K0GJCPMvvVNTC";

  /// Search data
  List<Map<String, dynamic>> _startSuggestions = [];
  List<Map<String, dynamic>> _destinationSuggestions = [];
  bool _showStartSuggestions = false;
  bool _showDestinationSuggestions = false;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  Timer? _debounceTimer;

  /// Trip Data
  bool isTracking = false;
  Timer? trackingTimer;
  DateTime? tripStartTime;
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    _startController.addListener(() => _onSearch(_startController.text, true));
    _destinationController.addListener(() => _onSearch(_destinationController.text, false));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    trackingTimer?.cancel();
    super.dispose();
  }

  /// ===================================================
  /// LOCATION FUNCTIONS
  /// ===================================================

  Future<void> _getCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final address = await LocationService.getAddressFromCoordinates(pos.latitude, pos.longitude);

      setState(() {
        currentLocation = LatLng(pos.latitude, pos.longitude);
        startLocationName = address;
        _startController.text = address;

        markers.add(
          Marker(
            markerId: const MarkerId("start"),
            position: currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: "Start", snippet: address),
          ),
        );
      });
    } catch (e) {
      _showError("Location error: $e");
    }
  }

  /// SEARCH WITH DEBOUNCE
  void _onSearch(String query, bool isStart) {
    _debounceTimer?.cancel();

    if (query.isEmpty || query.length < 3) {
      setState(() {
        if (isStart) {
          _startSuggestions = [];
          _showStartSuggestions = false;
        } else {
          _destinationSuggestions = [];
          _showDestinationSuggestions = false;
        }
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query, isStart);
    });
  }

  Future<void> _searchPlaces(String query, bool isStart) async {
    final data = await LocationService.searchLocation(query);

    setState(() {
      if (isStart) {
        _startSuggestions = data;
        _showStartSuggestions = data.isNotEmpty;
      } else {
        _destinationSuggestions = data;
        _showDestinationSuggestions = data.isNotEmpty;
      }
    });
  }

  /// SELECT PLACE
  Future<void> _selectPlace(Map<String, dynamic> place, bool isStart) async {
    final details = await LocationService.getPlaceDetails(place["place_id"]);
    if (details.isEmpty) return;

    final lat = details["lat"];
    final lng = details["lng"];
    final name = details["name"];

    setState(() {
      if (isStart) {
        currentLocation = LatLng(lat, lng);
        startLocationName = name;
        _startController.text = name;
        _showStartSuggestions = false;
      } else {
        destinationLocation = LatLng(lat, lng);
        destinationLocationName = name;
        _destinationController.text = name;
        _showDestinationSuggestions = false;
      }
      _updateMarkers();
    });

    if (currentLocation != null && destinationLocation != null) {
      _drawRoute();
    }
  }

  /// ===================================================
  /// MAP FUNCTIONS
  /// ===================================================

  void _updateMarkers() {
    markers.clear();

    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("start"),
          position: currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Start", snippet: startLocationName),
        ),
      );
    }

    if (destinationLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "Destination", snippet: destinationLocationName),
        ),
      );
    }
  }

  /// DRAW ROUTE USING GOOGLE DIRECTIONS
  Future<void> _drawRoute() async {
    if (currentLocation == null || destinationLocation == null) return;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
        destination: PointLatLng(destinationLocation!.latitude, destinationLocation!.longitude),
        mode: TravelMode.driving,
      ),
      googleApiKey: googleApiKey,
    );

    if (result.points.isEmpty) {
      _showError("Route not found!");
      return;
    }

    polylineCoordinates = result.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    setState(() {
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 6,
        ),
      );
    });
  }

  /// ===================================================
  /// UI
  /// ===================================================

  Widget _suggestionsBox(
      List<Map<String, dynamic>> suggestions,
      bool isStart,
      ) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (_, i) {
          final place = suggestions[i];
          return ListTile(
            leading: const Icon(Icons.location_on, color: Colors.orange),
            title: Text(place["name"], style: const TextStyle(color: Colors.white)),
            onTap: () => _selectPlace(place, isStart),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        title: const Text("Trip Tracker"),
        backgroundColor: const Color(0xFF16213e),
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation!,
              zoom: 14,
            ),
            onMapCreated: (c) => mapController = c,
            markers: markers,
            polylines: polylines,
            zoomControlsEnabled: false,
          ),

          /// SEARCH UI
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                _textField(
                  controller: _startController,
                  hint: "Start Location",
                  isStart: true,
                ),
                if (_showStartSuggestions)
                  _suggestionsBox(_startSuggestions, true),
                const SizedBox(height: 12),
                _textField(
                  controller: _destinationController,
                  hint: "Destination",
                  isStart: false,
                ),
                if (_showDestinationSuggestions)
                  _suggestionsBox(_destinationSuggestions, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required bool isStart,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(
            isStart ? Icons.my_location : Icons.location_on,
            color: Colors.orange,
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}
