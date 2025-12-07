import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import 'trip_end_form_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final int tripId;
  final String? startLocation;

  const LiveTrackingScreen({
    super.key,
    required this.tripId,
    this.startLocation,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _trackingTimer;

  Position? _currentPosition;
  Position? _startPosition; // ✅ STORE START POSITION
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];

  double _totalDistance = 0.0;
  DateTime? _startTime;
  String _elapsedTime = '00:00:00';
  String _startLocationAddress = 'Getting location...';

  bool _isTracking = true;
  bool _isLoadingAddress = true;

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
        debugPrint("❌ Location permission NOT granted");
        _showError("Location permission is required");
        return;
      }

      // Get initial position
      final position = await LocationService.getCurrentLocation();
      debugPrint('📍 Initial position: ${position.latitude}, ${position.longitude}');

      // ✅ CRITICAL: Store the actual start position
      _startPosition = position;

      // ✅ Get the REAL start location address from GPS
      try {
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (mounted) {
          setState(() {
            _startLocationAddress = address;
            _isLoadingAddress = false;
          });
        }

        debugPrint('✅ Start address captured: $address');
      } catch (e) {
        debugPrint('❌ Failed to get start address: $e');
        if (mounted) {
          setState(() {
            _startLocationAddress = 'Unknown location';
            _isLoadingAddress = false;
          });
        }
      }

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _routePoints.add(LatLng(position.latitude, position.longitude));
        });
      }

      // Start listening to GPS updates
      _positionSubscription = LocationService.getPositionStream().listen(
            (Position pos) {
          _onLocationUpdate(pos);
        },
        onError: (error) {
          debugPrint("❌ GPS STREAM ERROR => $error");
        },
      );

      debugPrint('✅ Tracking started successfully');
    } catch (e) {
      debugPrint("❌ Failed to start tracking: $e");
      _showError("Failed to start tracking: $e");
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
          _startLocationAddress = 'Error loading location';
        });
      }
    }
  }

  void _onLocationUpdate(Position position) async {
    if (!_isTracking || !mounted) return;

    setState(() {
      // Calculate distance from previous point
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

      // Update polyline to show the route
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

    // Move camera to follow current position
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );

    // Send tracking point to backend
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
      debugPrint('⚠️ Failed to send tracking point: $e');
    }
  }

  void _startTimeCounter() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null && mounted) {
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
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF16213e),
            title: const Text('Stop Tracking?', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Are you sure you want to stop tracking this trip? Your progress will be lost.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Stop', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (shouldPop == true) {
          _positionSubscription?.cancel();
          _trackingTimer?.cancel();
        }

        return shouldPop ?? false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            _currentPosition == null
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 16,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
              mapType: MapType.normal,
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: _buildInfoCard(),
            ),

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer, color: Color(0xFF00adb5), size: 20),
              const SizedBox(width: 8),
              Text(_elapsedTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00adb5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF00adb5), size: 16),
                    const SizedBox(width: 4),
                    Text(_isTracking ? 'Tracking' : 'Paused', style: const TextStyle(color: Color(0xFF00adb5), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem(icon: Icons.straighten, label: 'Distance', value: '${_totalDistance.toStringAsFixed(2)} km')),
              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.location_city,
                  label: 'Start',
                  value: _isLoadingAddress
                      ? 'Loading...'
                      : (_startLocationAddress.length > 20 ? '${_startLocationAddress.substring(0, 20)}...' : _startLocationAddress),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 16),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildEndTripButton() {
    return ElevatedButton(
      onPressed: _currentPosition == null ? null : _onEndTripPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFe94560),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: Colors.grey,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stop_circle, size: 24),
          SizedBox(width: 8),
          Text('End Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _onEndTripPressed() async {
    // ✅ CRITICAL FIX: Check if we have start position
    if (_currentPosition == null || _startPosition == null) {
      _showError("Cannot end trip: No location data");
      return;
    }

    setState(() => _isTracking = false);
    _positionSubscription?.cancel();
    _trackingTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final endAddress = await LocationService.getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      debugPrint('🏁 Trip ended');
      debugPrint('📍 Start: $_startLocationAddress (${_startPosition!.latitude}, ${_startPosition!.longitude})');
      debugPrint('📍 End: $endAddress (${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
      debugPrint('📊 Distance: ${_totalDistance.toStringAsFixed(2)} km');
      debugPrint('⏱️  Duration: ${DateTime.now().difference(_startTime!).inMinutes} min');

      if (mounted) Navigator.pop(context); // Dismiss loading

      if (mounted) {
        // ✅ CRITICAL FIX: Pass ALL required parameters including startLat and startLng
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TripEndFormScreen(
              tripId: widget.tripId,
              startLocation: _startLocationAddress,
              startLat: _startPosition!.latitude,  // ✅ FIXED: Add start coordinates
              startLng: _startPosition!.longitude, // ✅ FIXED: Add start coordinates
              endLat: _currentPosition!.latitude,
              endLng: _currentPosition!.longitude,
              endLocation: endAddress,
              distance: _totalDistance,
              duration: DateTime.now().difference(_startTime!).inMinutes,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error ending trip: $e');
      if (mounted) {
        Navigator.pop(context);
        _showError('Failed to end trip: $e');
      }
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }
}