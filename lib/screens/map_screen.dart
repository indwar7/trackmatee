import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'forms/trip_form_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;

  TextEditingController startController = TextEditingController();
  TextEditingController destController = TextEditingController();

  LatLng? startLatLng;
  LatLng? destLatLng;

  @override
  void initState() {
    super.initState();
    _askLocationPermission();
  }

  Future<void> _askLocationPermission() async {
    await Geolocator.requestPermission();
  }

  void _setPickedPoint(LatLng point) {
    setState(() {
      selectedLocation = point;
    });
  }

  double calculateDistance() {
    if (startLatLng == null || destLatLng == null) return 0.0;
    return Geolocator.distanceBetween(
      startLatLng!.latitude,
      startLatLng!.longitude,
      destLatLng!.latitude,
      destLatLng!.longitude,
    ) / 1000; // distance in km
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.6139, 77.2090),
              zoom: 14,
            ),
            onTap: _setPickedPoint,
            onMapCreated: (controller) => mapController = controller,
            markers: selectedLocation != null
                ? {
              Marker(
                markerId: const MarkerId("picked"),
                position: selectedLocation!,
              )
            }
                : {},
          ),

          // Floating Location Input Fields
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                buildFloatingInput(
                  label: "Start Location",
                  controller: startController,
                  onChanged: (val) {
                    startLatLng = const LatLng(28.6315, 77.2167);
                  },
                ),
                const SizedBox(height: 10),
                buildFloatingInput(
                  label: "Destination",
                  controller: destController,
                  onChanged: (val) {
                    destLatLng = const LatLng(15.5437, 73.7553);
                  },
                ),
              ],
            ),
          ),

          // Confirm Trip Button
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (startLatLng == null || destLatLng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter start & destination"),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripFormScreen(
                      startLat: startLatLng!.latitude,
                      startLng: startLatLng!.longitude,
                      destLat: destLatLng!.latitude,
                      destLng: destLatLng!.longitude,
                      startAddress: startController.text,
                      destAddress: destController.text,
                      distance: calculateDistance(),
                    ),
                  ),
                );
              },
              child: const Text(
                "Confirm Trip",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFloatingInput({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black), // ← black font
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white, // white background for inputs
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
