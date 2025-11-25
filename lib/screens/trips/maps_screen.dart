import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  final Map<String, dynamic>? route;
  const MapsScreen({Key? key, this.route}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(28.7041, 77.1025); // Centered on Delhi
  final Set<Polyline> _polylines = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (widget.route != null) {
      _drawRoute(widget.route!);
    }
  }

  void _drawRoute(Map<String, dynamic> route) {
    // In a real app, you would decode the polyline string here.
    // This is a placeholder for demonstration.
    final List<LatLng> polylineCoordinates = [
      const LatLng(28.7041, 77.1025),
      const LatLng(28.5355, 77.3910),
    ];

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          visible: true,
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('maps'.tr),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        polylines: _polylines,
      ),
    );
  }
}
