import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../screens/forms/trip_form_screen.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  LatLng? currentLatLng;
  List<LatLng> polyPoints = [];
  StreamSubscription<Position>? positionStream;
  double totalDistance = 0.0;

  bool isTracking = false;

  // Trip metadata
  DateTime? tripStartTime;
  DateTime? tripEndTime;
  LatLng? startLocation;
  LatLng? endLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ---------------------------- LOCATION ACCESS ---------------------------- //
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(pos.latitude, pos.longitude);
    });
  }

  // ------------------------- START TRACKING ----------------------------- //
  void _startTracking() async {
    if (currentLatLng == null) return;

    isTracking = true;
    polyPoints = [];
    totalDistance = 0;

    tripStartTime = DateTime.now();
    startLocation = currentLatLng;

    polyPoints.add(currentLatLng!);

    positionStream = Geolocator.getPositionStream().listen((Position pos) {
      LatLng newPoint = LatLng(pos.latitude, pos.longitude);

      if (polyPoints.isNotEmpty) {
        totalDistance += _calculateDistance(
          polyPoints.last.latitude,
          polyPoints.last.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );
      }

      setState(() {
        polyPoints.add(newPoint);
        currentLatLng = newPoint;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLng(newPoint),
      );
    });

    setState(() {});
  }

  // ------------------------- STOP TRACKING ----------------------------- //
  void _stopTracking() {
    if (positionStream != null) {
      positionStream!.cancel();
    }

    tripEndTime = DateTime.now();
    endLocation = currentLatLng;

    setState(() {
      isTracking = false;
    });

    // Navigate to TripFormScreen with all auto-filled data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripFormScreen(
          polyPoints: polyPoints,
          distance: totalDistance,
          startLocation:
          "${startLocation!.latitude}, ${startLocation!.longitude}",
          endLocation: "${endLocation!.latitude}, ${endLocation!.longitude}",
          startTime: tripStartTime!,
          endTime: tripEndTime!,
          modeOfTravel: "Car", // default, user can change in form
        ),
      ),
    );
  }

  // ------------------------------ DISTANCE CALC --------------------------- //
  double _calculateDistance(lat1, lon1, lat2, lon2) {
    const p = 0.017453292519943295; // pi/180
    final a = 0.5 -
        (cos((lat2 - lat1) * p) / 2) +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a)); // 2*R*asin...
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  // ----------------------------- UI --------------------------------------- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto Tracking"),
        backgroundColor: Colors.black87,
      ),
      body: currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLatLng!,
          zoom: 16,
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId("tracking"),
            points: polyPoints,
            width: 5,
            color: Colors.blue,
          ),
        },
        markers: {
          Marker(
            markerId: const MarkerId("current"),
            position: currentLatLng!,
          )
        },
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // START BUTTON
          if (!isTracking)
            FloatingActionButton.extended(
              onPressed: _startTracking,
              label: const Text("Start Tracking"),
              backgroundColor: Colors.green,
            ),
          const SizedBox(height: 10),

          // STOP BUTTON
          if (isTracking)
            FloatingActionButton.extended(
              onPressed: _stopTracking,
              label: const Text("Stop & Save"),
              backgroundColor: Colors.red,
            ),
        ],
      ),
    );
  }
}
