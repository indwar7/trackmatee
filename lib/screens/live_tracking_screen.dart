import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/location_service.dart';
import 'trip_end_form_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final int tripId;
  final String startLocation;

  const LiveTrackingScreen({
    super.key,
    required this.tripId,
    required this.startLocation,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _trackingTimer;

  Position? _currentPosition;
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];

  double _totalDistance = 0.0;
  DateTime? _startTime;
  String _elapsedTime = '00:00:00';

  bool _isTracking = true;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTracking();
    _startTimeCounter();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _trackingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startTracking() async {
    try {
      bool ok = await LocationService.checkPermissions();
      if (!ok) {
        debugPrint("Location permission NOT granted");
        return;
      }

      // Get initial position
      final position = await LocationService.getCurrentLocation();

      setState(() {
        _currentPosition = position;
        _routePoints.add(LatLng(position.latitude, position.longitude));
      });

      // Start listening to GPS updates
      _positionSubscription = LocationService.getPositionStream().listen(
            (Position pos) {
          _onLocationUpdate(pos);
        },
        onError: (error) {
          debugPrint("STREAM ERROR => $error");
        },
      );
    } catch (e) {
      debugPrint("Failed to start tracking: $e");
    }
  }

  void _onLocationUpdate(Position position) async {
    if (!_isTracking) return;

    setState(() {
      // Calculate distance
      if (_currentPosition != null) {
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance / 1000; // Convert to km
      }

      _currentPosition = position;
      _routePoints.add(LatLng(position.latitude, position.longitude));

      // Update polyline
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routePoints,
          color: const Color(0xFF00adb5),
          width: 5,
        ),
      );
    });

    // Move camera to current position
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );

    // Send tracking point to API
    try {
      final apiService = context.read<ApiService>();
      await apiService.addTrackingPoint(
        tripId: widget.tripId,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
      );
    } catch (e) {
      debugPrint('Failed to send tracking point: $e');
    }
  }

  void _startTimeCounter() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final duration = DateTime.now().difference(_startTime!);
        setState(() {
          _elapsedTime = _formatDuration(duration);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Allow going back without ending trip
        _positionSubscription?.cancel();
        _trackingTimer?.cancel();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Google Map
            _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 16,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
              mapType: MapType.normal,
            ),

            // Top Info Card
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: _buildInfoCard(),
            ),

            // End Trip Button
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: _buildEndTripButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer,
                color: Color(0xFF00adb5),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _elapsedTime,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00adb5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Color(0xFF00adb5),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Tracking',
                      style: TextStyle(
                        color: Color(0xFF00adb5),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${_totalDistance.toStringAsFixed(2)} km',
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.location_city,
                  label: 'Start',
                  value: widget.startLocation.length > 15
                      ? '${widget.startLocation.substring(0, 15)}...'
                      : widget.startLocation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEndTripButton() {
    return ElevatedButton(
      onPressed: _onEndTripPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFe94560),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stop_circle, size: 24),
          SizedBox(width: 8),
          Text(
            'End Trip',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _onEndTripPressed() async {
    // Stop tracking
    setState(() => _isTracking = false);
    _positionSubscription?.cancel();
    _trackingTimer?.cancel();

    if (_currentPosition == null) {
      _showError("Cannot end trip: No location data");
      return;
    }

    // Get end location address
    final endAddress = await LocationService.getAddressFromCoordinates(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // Navigate to form with map-based destination selection
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TripEndFormScreen(
            tripId: widget.tripId,
            startLocation: widget.startLocation,
            endLat: _currentPosition!.latitude,
            endLng: _currentPosition!.longitude,
            endLocation: endAddress,
            distance: _totalDistance,
            duration: DateTime.now().difference(_startTime!).inMinutes,
          ),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}