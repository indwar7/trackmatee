import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'services/directions_service.dart';
import 'search_destination.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  LatLng? destinationLocation;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  StreamSubscription<Position>? positionStream;

  String distanceText = "";
  String durationText = "";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentLocation = LatLng(pos.latitude, pos.longitude);

    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId("current"),
          position: currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation!, 15),
    );

    _trackMovement();
  }

  void _trackMovement() {
    positionStream =
        Geolocator.getPositionStream().listen((Position newPos) async {
          currentLocation = LatLng(newPos.latitude, newPos.longitude);

          setState(() {
            markers.removeWhere((m) => m.markerId.value == "current");
            markers.add(
              Marker(
                markerId: const MarkerId("current"),
                position: currentLocation!,
                icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            );
          });

          if (destinationLocation != null) {
            await _updateRoute();
          }
        });
  }

  Future<void> chooseDestination() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchDestinationScreen(),
      ),
    );

    if (result == null) return;

    destinationLocation = LatLng(result.lat, result.lng);

    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });

    await _updateRoute();
  }

  Future<void> _updateRoute() async {
    if (currentLocation == null || destinationLocation == null) return;

    final route = await DirectionsService.getRoutePoints(
      currentLocation!,
      destinationLocation!,
    );

    polylines.clear();
    polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        width: 5,
        points: route.points,
      ),
    );

    setState(() {
      distanceText = route.distance;
      durationText = route.duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Navigation"),
        actions: [
          IconButton(
            onPressed: chooseDestination,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation!,
              zoom: 15,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            onMapCreated: (controller) => mapController = controller,
          ),

          if (distanceText.isNotEmpty)
            Positioned(
              left: 10,
              right: 10,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3)),
                  ],
                ),
                child: Text(
                  "Distance: $distanceText   |   Time: $durationText",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: chooseDestination,
        label: const Text("Set Destination"),
        icon: const Icon(Icons.place),
      ),
    );
  }
}
