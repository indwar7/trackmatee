import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../services/location_service.dart';
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
  List<LatLng> polylineCoordinates = [];

  final polylinePoints = PolylinePoints();
  final String googleApiKey = "AIzaSyCvuze7W6e4S_5bSAEuX9K0GJCPMvvVNTQ";

  // Trip tracking
  bool isTracking = false;
  DateTime? tripStartTime;
  Timer? trackingTimer;
  double totalDistance = 0.0;
  List<LatLng> travelledPath = [];

  // Text controllers for location input
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  // Search suggestions
  List<Map<String, dynamic>> _startSuggestions = [];
  List<Map<String, dynamic>> _destinationSuggestions = [];
  bool _showStartSuggestions = false;
  bool _showDestinationSuggestions = false;

  // Debounce timer for search
  Timer? _debounceTimer;

  // Loading states
  bool _isLoadingStartSuggestions = false;
  bool _isLoadingDestSuggestions = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();

    // Listen to text changes for autocomplete
    _startController.addListener(_onStartTextChanged);
    _destinationController.addListener(_onDestinationTextChanged);

    // Add focus listeners
    _startFocusNode.addListener(_onStartFocusChanged);
    _destinationFocusNode.addListener(_onDestinationFocusChanged);
  }

  @override
  void dispose() {
    trackingTimer?.cancel();
    _debounceTimer?.cancel();
    _startController.dispose();
    _destinationController.dispose();
    _startFocusNode.dispose();
    _destinationFocusNode.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void _onStartFocusChanged() {
    if (!_startFocusNode.hasFocus) {
      // Delay hiding to allow tap on suggestion
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showStartSuggestions = false;
          });
        }
      });
    }
  }

  void _onDestinationFocusChanged() {
    if (!_destinationFocusNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _showDestinationSuggestions = false;
          });
        }
      });
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final address = await LocationService.getAddressFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      setState(() {
        currentLocation = LatLng(pos.latitude, pos.longitude);
        startLocationName = address;
        _startController.text = address;

        markers.add(
          Marker(
            markerId: const MarkerId("start"),
            position: currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: "Start Location", snippet: address),
          ),
        );
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 15),
      );
    } catch (e) {
      print("ERROR: Failed to get current location: $e");
      _showError("Failed to get current location: $e");
    }
  }

  void _onStartTextChanged() {
    final query = _startController.text;

    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _showStartSuggestions = false;
        _startSuggestions = [];
        _isLoadingStartSuggestions = false;
      });
      return;
    }

    if (query.length >= 3) {
      setState(() {
        _isLoadingStartSuggestions = true;
      });

      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _searchStartLocation(query);
      });
    }
  }

  void _onDestinationTextChanged() {
    final query = _destinationController.text;

    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _showDestinationSuggestions = false;
        _destinationSuggestions = [];
        _isLoadingDestSuggestions = false;
      });
      return;
    }

    if (query.length >= 3) {
      setState(() {
        _isLoadingDestSuggestions = true;
      });

      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _searchDestinationLocation(query);
      });
    }
  }

  Future<void> _searchStartLocation(String query) async {
    try {
      print("🔍 Searching start location: $query");
      final suggestions = await LocationService.searchLocation(query);
      print("✅ Found ${suggestions.length} start suggestions");

      if (mounted) {
        setState(() {
          _startSuggestions = suggestions;
          _showStartSuggestions = suggestions.isNotEmpty;
          _isLoadingStartSuggestions = false;
        });

        if (suggestions.isEmpty) {
          _showError("No locations found for '$query'");
        }
      }
    } catch (e) {
      print("❌ Error fetching start suggestions: $e");
      if (mounted) {
        setState(() {
          _isLoadingStartSuggestions = false;
        });
        _showError("Search failed: $e");
      }
    }
  }

  Future<void> _searchDestinationLocation(String query) async {
    try {
      print("🔍 Searching destination location: $query");
      final suggestions = await LocationService.searchLocation(query);
      print("✅ Found ${suggestions.length} destination suggestions");

      if (mounted) {
        setState(() {
          _destinationSuggestions = suggestions;
          _showDestinationSuggestions = suggestions.isNotEmpty;
          _isLoadingDestSuggestions = false;
        });

        if (suggestions.isEmpty) {
          _showError("No locations found for '$query'");
        }
      }
    } catch (e) {
      print("❌ Error fetching destination suggestions: $e");
      if (mounted) {
        setState(() {
          _isLoadingDestSuggestions = false;
        });
        _showError("Search failed: $e");
      }
    }
  }

  void _selectStartLocation(Map<String, dynamic> place) async {
    final lat = place['lat'];
    final lng = place['lng'];
    final name = place['name'];

    print("✓ Selected start location: $name");

    setState(() {
      currentLocation = LatLng(lat, lng);
      startLocationName = name;
      _startController.text = name;
      _showStartSuggestions = false;

      markers.removeWhere((m) => m.markerId.value == "start");
      markers.add(
        Marker(
          markerId: const MarkerId("start"),
          position: currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Start Location", snippet: name),
        ),
      );
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation!));
    _startFocusNode.unfocus();

    if (destinationLocation != null) {
      await drawRoute();
    }
  }

  void _selectDestinationLocation(Map<String, dynamic> place) async {
    final lat = place['lat'];
    final lng = place['lng'];
    final name = place['name'];

    print("✓ Selected destination: $name at ($lat, $lng)");

    setState(() {
      destinationLocation = LatLng(lat, lng);
      destinationLocationName = name;
      _destinationController.text = name;
      _showDestinationSuggestions = false;

      markers.removeWhere((m) => m.markerId.value == "destination");
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "Destination", snippet: name),
        ),
      );
    });

    _destinationFocusNode.unfocus();

    await drawRoute();
  }

  Future<void> drawRoute() async {
    if (currentLocation == null || destinationLocation == null) {
      print("Cannot draw route: missing locations");
      return;
    }

    print("Drawing route...");

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
          destination: PointLatLng(destinationLocation!.latitude, destinationLocation!.longitude),
          mode: TravelMode.driving,
        ),
        googleApiKey: googleApiKey,
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();

        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          polylines.clear();
          polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.blue,
              width: 8,
              points: polylineCoordinates,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              geodesic: true,
            ),
          );
        });

        _fitRouteBounds();
        _showSuccess("Route displayed successfully!");
      } else {
        _showError("No route found between locations");
      }
    } catch (e) {
      print("Error drawing route: $e");
      _showError("Failed to draw route: $e");
    }
  }

  void _fitRouteBounds() {
    if (currentLocation == null || destinationLocation == null) return;

    double minLat = currentLocation!.latitude < destinationLocation!.latitude
        ? currentLocation!.latitude
        : destinationLocation!.latitude;
    double maxLat = currentLocation!.latitude > destinationLocation!.latitude
        ? currentLocation!.latitude
        : destinationLocation!.latitude;
    double minLng = currentLocation!.longitude < destinationLocation!.longitude
        ? currentLocation!.longitude
        : destinationLocation!.longitude;
    double maxLng = currentLocation!.longitude > destinationLocation!.longitude
        ? currentLocation!.longitude
        : destinationLocation!.longitude;

    double latPadding = (maxLat - minLat) * 0.1;
    double lngPadding = (maxLng - minLng) * 0.1;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Future<void> selectDestination(LatLng point) async {
    if (isTracking) return;

    print("Map tapped at: ${point.latitude}, ${point.longitude}");

    final address = await LocationService.getAddressFromCoordinates(
      point.latitude,
      point.longitude,
    );

    setState(() {
      destinationLocation = point;
      destinationLocationName = address;
      _destinationController.text = address;

      markers.removeWhere((m) => m.markerId.value == "destination");
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "Destination", snippet: address),
        ),
      );
    });

    await drawRoute();
  }

  void _startTracking() {
    if (destinationLocation == null) {
      _showError("Please select a destination first");
      return;
    }

    setState(() {
      isTracking = true;
      tripStartTime = DateTime.now();
      totalDistance = 0.0;
      travelledPath = [currentLocation!];
    });

    trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateLocation();
    });

    _showSuccess("Trip tracking started!");
  }

  Future<void> _updateLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newLocation = LatLng(pos.latitude, pos.longitude);

      if (travelledPath.isNotEmpty) {
        double distance = Geolocator.distanceBetween(
          travelledPath.last.latitude,
          travelledPath.last.longitude,
          newLocation.latitude,
          newLocation.longitude,
        );
        totalDistance += distance / 1000;
      }

      setState(() {
        currentLocation = newLocation;
        travelledPath.add(newLocation);

        markers.removeWhere((m) => m.markerId.value == "start");
        markers.add(
          Marker(
            markerId: const MarkerId("start"),
            position: currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: "Current Location"),
          ),
        );

        polylines.removeWhere((p) => p.polylineId.value == "travelled");
        polylines.add(
          Polyline(
            polylineId: const PolylineId("travelled"),
            color: Colors.greenAccent,
            width: 8,
            points: travelledPath,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      });
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  void _stopTracking() {
    if (!isTracking) return;

    trackingTimer?.cancel();

    final duration = DateTime.now().difference(tripStartTime!).inMinutes;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripEndFormScreen(
          tripId: DateTime.now().millisecondsSinceEpoch,
          startLocation: startLocationName ?? "Unknown",
          endLat: destinationLocation!.latitude,
          endLng: destinationLocation!.longitude,
          endLocation: destinationLocationName ?? "Unknown",
          distance: totalDistance,
          duration: duration > 0 ? duration : 1,
        ),
      ),
    );

    setState(() {
      isTracking = false;
      tripStartTime = null;
      totalDistance = 0.0;
      travelledPath.clear();
      polylines.removeWhere((p) => p.polylineId.value == "travelled");
    });
  }

  Widget _buildSuggestionsList({
    required List<Map<String, dynamic>> suggestions,
    required bool isLoading,
    required Function(Map<String, dynamic>) onSelect,
    required Color iconColor,
  }) {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00adb5),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final place = suggestions[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(place),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: iconColor, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        place['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        centerTitle: true,
        backgroundColor: const Color(0xFF16213e),
        actions: [
          // Debug/Test button
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () async {
              print("=== MANUAL TEST ===");
              final results = await LocationService.searchLocation("delhi");
              print("Test results: ${results.length}");
              if (results.isNotEmpty) {
                _showSuccess("API Working! Found ${results.length} results");
              } else {
                _showError("API test failed - no results");
              }
            },
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00adb5)))
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation!,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            onTap: selectDestination,
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),

          // Location input boxes with suggestions
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Start location input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _startController,
                        focusNode: _startFocusNode,
                        style: const TextStyle(color: Colors.white),
                        enabled: !isTracking,
                        decoration: InputDecoration(
                          hintText: "Enter start location",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: const Icon(Icons.my_location, color: Color(0xFF00adb5)),
                          suffixIcon: _startController.text.isNotEmpty && !isTracking
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _startController.clear();
                            },
                          )
                              : null,
                        ),
                      ),
                      if (_showStartSuggestions)
                        _buildSuggestionsList(
                          suggestions: _startSuggestions,
                          isLoading: _isLoadingStartSuggestions,
                          onSelect: _selectStartLocation,
                          iconColor: Color(0xFF00adb5),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Destination location input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213e),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _destinationController,
                        focusNode: _destinationFocusNode,
                        style: const TextStyle(color: Colors.white),
                        enabled: !isTracking,
                        decoration: InputDecoration(
                          hintText: "Enter destination or tap on map",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                          suffixIcon: _destinationController.text.isNotEmpty && !isTracking
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _destinationController.clear();
                              setState(() {
                                destinationLocation = null;
                                destinationLocationName = null;
                                markers.removeWhere((m) => m.markerId.value == "destination");
                                polylines.clear();
                              });
                            },
                          )
                              : null,
                        ),
                      ),
                      if (_showDestinationSuggestions)
                        _buildSuggestionsList(
                          suggestions: _destinationSuggestions,
                          isLoading: _isLoadingDestSuggestions,
                          onSelect: _selectDestinationLocation,
                          iconColor: Colors.red,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tracking info panel
          if (isTracking)
            Positioned(
              top: 280,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Tracking in Progress",
                          style: TextStyle(
                            color: Color(0xFF00adb5),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip(
                          Icons.straighten,
                          "${totalDistance.toStringAsFixed(2)} km",
                        ),
                        _buildInfoChip(
                          Icons.timer,
                          "${DateTime.now().difference(tripStartTime!).inMinutes} min",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Control buttons
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: isTracking
                ? ElevatedButton.icon(
              onPressed: _stopTracking,
              icon: const Icon(Icons.stop, color: Colors.white),
              label: const Text("Stop Tracking", style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
                : ElevatedButton.icon(
              onPressed: destinationLocation == null ? null : _startTracking,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text("Start Tracking", style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00adb5),
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f1e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00adb5), size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }
}