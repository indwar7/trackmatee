import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class TripMapsScreen extends StatefulWidget {
  final String? tripId;              // supports passing trip reference later
  final LatLng? startPoint;
  final LatLng? endPoint;

  const TripMapsScreen({
    Key? key,
    this.tripId,
    this.startPoint,
    this.endPoint,
  }) : super(key: key);

  @override
  State<TripMapsScreen> createState() => _TripMapsScreenState();
}

class _TripMapsScreenState extends State<TripMapsScreen> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polyLines = {};
  LatLng defaultStart = const LatLng(19.0760, 72.8777); // Mumbai fallback
  LatLng defaultEnd   = const LatLng(18.5204, 73.8567); // Pune fallback

  @override
  void initState() {
    super.initState();
    initializeRoute();
  }

  void initializeRoute() {
    final start = widget.startPoint ?? defaultStart;
    final end   = widget.endPoint ?? defaultEnd;

    markers.add(Marker(
      markerId: const MarkerId("start"),
      position: start,
      infoWindow: const InfoWindow(title: "Start Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    markers.add(Marker(
      markerId: const MarkerId("end"),
      position: end,
      infoWindow: const InfoWindow(title: "Destination"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));

    polyLines.add(Polyline(
      polylineId: const PolylineId("trip_route"),
      points: [start, end],
      width: 5,
      color: Colors.deepPurpleAccent,
    ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          "Trip Route",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: GoogleMap(
        markers: markers,
        polylines: polyLines,
        initialCameraPosition: CameraPosition(
          target: widget.startPoint ?? defaultStart,
          zoom: 10,
        ),
        onMapCreated: (controller) => mapController = controller,
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        height: 140,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A3E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Trip Summary",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _tile(icon: Icons.timer, label: "Time", value: "1h 45m"),
                _tile(icon: Icons.route, label: "Distance", value: "154 Km"),
                _tile(icon: Icons.speed, label: "Avg Speed", value: "68 Km/h"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _tile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurpleAccent, size: 26),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
