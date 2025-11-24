import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  final TextEditingController startController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  LatLng? currentLocation;
  LatLng? startLocation;
  LatLng? destinationLocation;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  StreamSubscription<Position>? positionStream;

  // Insert your API KEY ⬇
  final String apiKey = "AIzaSyCvuze7W6e4S_5bSAEuX9K0GJCPMvvVNTQ";

  @override
  void initState() {
    super.initState();
    _initLocationUpdates();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  // -----------------------------------------
  // 1. LIVE LOCATION TRACKING
  // -----------------------------------------
  void _initLocationUpdates() async {
    await Geolocator.requestPermission();

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      currentLocation = LatLng(pos.latitude, pos.longitude);

      // If user didn't type a custom start location,
      // use real-time current location as start.
      if ((startController.text.isEmpty)) {
        startLocation = currentLocation;
      }

      _updateMarkers();

      if (destinationLocation != null) {
        _getRoute();
      }
    });
  }

  // -----------------------------------------
  // 2. GOOGLE PLACES AUTOCOMPLETE
  // -----------------------------------------
  Future<LatLng?> _searchPlace(String query) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    if (data["results"].isEmpty) return null;

    final loc = data["results"][0]["geometry"]["location"];
    return LatLng(loc["lat"], loc["lng"]);
  }

  // -----------------------------------------
  // 3. GET ROUTE USING GOOGLE DIRECTIONS API
  // -----------------------------------------
  Future<void> _getRoute() async {
    if (startLocation == null || destinationLocation == null) return;

    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${startLocation!.latitude},${startLocation!.longitude}"
        "&destination=${destinationLocation!.latitude},${destinationLocation!.longitude}"
        "&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    if (data["routes"].isEmpty) return;

    final points = data["routes"][0]["overview_polyline"]["points"];
    final lineCoords = _decodePolyline(points);

    setState(() {
      polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          points: lineCoords,
          width: 5,
          color: Colors.blue,
        )
      };
    });
  }

  // Polyline decoder
  List<LatLng> _decodePolyline(String poly) {
    List<LatLng> points = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // -----------------------------------------
  // 4. UPDATE MAP MARKERS
  // -----------------------------------------
  void _updateMarkers() {
    markers.clear();

    if (startLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("start"),
          position: startLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    if (destinationLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    setState(() {});
  }

  // -----------------------------------------
  // 5. DARK MAP STYLE
  // -----------------------------------------
  final String darkMapStyle = jsonEncode([
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#38414e"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#0e1626"}]
    }
  ]);

  // -----------------------------------------
  // UI
  // -----------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // GOOGLE MAPS
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.6139, 77.2090),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              controller.setMapStyle(darkMapStyle);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: markers,
            polylines: polylines,
          ),

          // INPUT BOXES (FIXED — fully typeable)
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Column(
              children: [
                _inputBox(
                  controller: startController,
                  hint: "Start location (or use GPS)",
                  onSubmitted: (txt) async {
                    if (txt.isEmpty) return;
                    final loc = await _searchPlace(txt);
                    if (loc != null) {
                      startLocation = loc;
                      _updateMarkers();
                      _getRoute();
                      mapController?.animateCamera(
                        CameraUpdate.newLatLng(loc),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                _inputBox(
                  controller: destinationController,
                  hint: "Destination",
                  onSubmitted: (txt) async {
                    if (txt.isEmpty) return;
                    final loc = await _searchPlace(txt);
                    if (loc != null) {
                      destinationLocation = loc;
                      _updateMarkers();
                      _getRoute();
                      mapController?.animateCamera(
                        CameraUpdate.newLatLng(loc),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required Function(String) onSubmitted,
  }) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(14),
      color: Colors.black.withOpacity(0.75),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
