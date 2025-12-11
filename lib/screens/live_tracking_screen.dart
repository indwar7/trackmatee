import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/travel_mode_detector.dart';
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
  Timer? _inactivityTimer;

  Position? _currentPosition;
  Position? _startPosition;
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];

  double _totalDistance = 0.0;
  DateTime? _startTime;
  String _elapsedTime = '00:00:00';
  String _startLocationAddress = 'Getting location...';

  bool _isTracking = true;
  bool _isLoadingAddress = true;
  int? _actualTripId;

  // Travel mode detection
  final TravelModeDetector _modeDetector = TravelModeDetector();
  String _detectedMode = 'Stationary';
  String _confidence = 'High';
  double _currentSpeed = 0.0;

  // Auto-end trip feature
  DateTime? _lastSignificantMovement;
  static const double _movementThreshold = 50.0; // 50 meters
  static const Duration _inactivityDuration = Duration(minutes: 5);
  Position? _lastMovementPosition;

  // ✅ NEW: Speed smoothing buffer
  final List<double> _speedBuffer = [];
  static const int _speedBufferSize = 5; // Average last 5 readings

  // ✅ NEW: Position validation
  Position? _lastValidPosition;
  DateTime? _lastValidPositionTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _lastSignificantMovement = DateTime.now();
    _startTracking();
    _startTimeCounter();
    _startInactivityMonitor();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _trackingTimer?.cancel();
    _inactivityTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startInactivityMonitor() {
    // Check every 1 minute if user hasn't moved
    _inactivityTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!_isTracking || _lastSignificantMovement == null) return;

      final inactiveDuration = DateTime.now().difference(_lastSignificantMovement!);

      debugPrint('🔍 Inactivity check: ${inactiveDuration.inMinutes} minutes since last movement');

      if (inactiveDuration >= _inactivityDuration) {
        debugPrint('⏰ 5 minutes of inactivity detected - Auto-ending trip');
        _autoEndTrip();
      }
    });
  }

  void _checkForSignificantMovement(Position newPosition) {
    if (_lastMovementPosition == null) {
      _lastMovementPosition = newPosition;
      _lastSignificantMovement = DateTime.now();
      return;
    }

    final distance = Geolocator.distanceBetween(
      _lastMovementPosition!.latitude,
      _lastMovementPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (distance >= _movementThreshold) {
      debugPrint('✅ Significant movement detected: ${distance.toStringAsFixed(1)}m');
      _lastMovementPosition = newPosition;
      _lastSignificantMovement = DateTime.now();
    }
  }

  Future<void> _autoEndTrip() async {
    if (!mounted || !_isTracking) return;

    debugPrint('🤖 Auto-ending trip due to 5 minutes of inactivity');

    // Show notification to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip automatically ended due to 5 minutes of no movement'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }

    // End the trip
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _onEndTripPressed(autoEnded: true);
    }
  }

  // ✅ NEW: Validate if position update is real movement or GPS noise
  bool _isRealMovement(Position newPosition) {
    if (_lastValidPosition == null) {
      _lastValidPosition = newPosition;
      _lastValidPositionTime = DateTime.now();
      return false; // First position, no movement yet
    }

    final distance = Geolocator.distanceBetween(
      _lastValidPosition!.latitude,
      _lastValidPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    final timeDiff = DateTime.now().difference(_lastValidPositionTime!).inSeconds;

    // Calculate dynamic threshold based on accuracy
    final accuracyThreshold = (newPosition.accuracy + _lastValidPosition!.accuracy) / 2;
    final minimumDistance = accuracyThreshold * 1.5; // Movement must be 1.5x the accuracy

    debugPrint('📏 Distance: ${distance.toStringAsFixed(1)}m | Threshold: ${minimumDistance.toStringAsFixed(1)}m | Time: ${timeDiff}s');

    // Real movement criteria:
    // 1. Distance > accuracy threshold
    // 2. Good accuracy (< 30m)
    // 3. Reasonable time passed (> 2 seconds)
    if (distance > minimumDistance && newPosition.accuracy < 30 && timeDiff >= 2) {
      _lastValidPosition = newPosition;
      _lastValidPositionTime = DateTime.now();
      return true;
    }

    return false;
  }

  // ✅ NEW: Calculate smoothed speed
  double _calculateSmoothedSpeed(Position position) {
    double calculatedSpeed = 0.0;

    if (_lastValidPosition != null && _lastValidPositionTime != null) {
      final distance = Geolocator.distanceBetween(
        _lastValidPosition!.latitude,
        _lastValidPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      final timeDiff = DateTime.now().difference(_lastValidPositionTime!).inSeconds;

      if (timeDiff > 0 && distance > 0) {
        calculatedSpeed = distance / timeDiff; // m/s
      }
    }

    // Add to buffer
    _speedBuffer.add(calculatedSpeed);
    if (_speedBuffer.length > _speedBufferSize) {
      _speedBuffer.removeAt(0);
    }

    // Return average of buffer
    if (_speedBuffer.isEmpty) return 0.0;
    return _speedBuffer.reduce((a, b) => a + b) / _speedBuffer.length;
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
      debugPrint('📍 Initial accuracy: ${position.accuracy}m');

      // Store the actual start position
      _startPosition = position;
      _lastMovementPosition = position;
      _lastSignificantMovement = DateTime.now();
      _lastValidPosition = position;
      _lastValidPositionTime = DateTime.now();

      // Get the REAL start location address from GPS
      String? startAddress;
      try {
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        startAddress = address;
        if (mounted) {
          setState(() {
            _startLocationAddress = address;
            _isLoadingAddress = false;
          });
        }

        debugPrint('✅ Start address captured: $address');
      } catch (e) {
        debugPrint('❌ Failed to get start address: $e');
        startAddress = widget.startLocation;
        if (mounted) {
          setState(() {
            _startLocationAddress = startAddress ?? 'Unknown location';
            _isLoadingAddress = false;
          });
        }
      }

      // Call startTrip API to create trip in database
      try {
        final apiService = context.read<ApiService>();
        await apiService.loadTokens();

        if (apiService.accessToken == null || apiService.accessToken!.isEmpty) {
          debugPrint('❌ No token available to start trip');
          _showError("Authentication required. Please login again.");
          return;
        }

        debugPrint('🚀 Starting trip via API...');
        debugPrint('   Start Lat: ${position.latitude}, Lng: ${position.longitude}');
        debugPrint('   Location: ${startAddress ?? widget.startLocation}');

        final tripData = await apiService.startTrip(
          startLat: position.latitude,
          startLng: position.longitude,
          locationName: startAddress ?? widget.startLocation,
        );

        debugPrint('📦 [LiveTracking] StartTrip response: $tripData');

        // Check if this is an ongoing trip
        if (tripData.containsKey('ongoing_trip') && tripData['ongoing_trip'] == true) {
          final tripNumber = tripData['trip_number'] ?? 'Unknown';
          debugPrint('⚠️ [LiveTracking] Using ongoing trip: $tripNumber');

          if (tripData.containsKey('id')) {
            final idValue = tripData['id'];
            _actualTripId = idValue is int ? idValue : int.tryParse(idValue.toString());
            if (_actualTripId != null && _actualTripId! > 0) {
              debugPrint('✅ Resumed ongoing trip! Trip ID: $_actualTripId');
            }
          }
        }
        // Normal case: Check nested trip.id first
        else if (tripData.containsKey('trip') &&
            tripData['trip'] is Map<String, dynamic>) {
          final tripObj = tripData['trip'] as Map<String, dynamic>;
          if (tripObj.containsKey('id')) {
            final idValue = tripObj['id'];

            if (idValue is int) {
              _actualTripId = idValue;
            } else if (idValue is String) {
              _actualTripId = int.tryParse(idValue);
            } else {
              debugPrint('❌ Invalid trip ID type in nested trip: ${idValue.runtimeType}');
              _showError("Server returned invalid trip ID format");
              return;
            }

            if (_actualTripId != null && _actualTripId! > 0) {
              debugPrint('✅ Trip started successfully! Trip ID: $_actualTripId (from nested trip)');
            } else {
              debugPrint('❌ Invalid or missing trip ID in nested trip: $idValue');
              _showError("Failed to get valid trip ID from server");
              return;
            }
          } else {
            debugPrint('❌ No "id" in nested trip object. Available keys: ${tripObj.keys.toList()}');
            _showError("Server did not return trip ID in nested trip");
            return;
          }
        }
        // Fallback: Try direct id field
        else if (tripData.containsKey('id')) {
          final idValue = tripData['id'];

          if (idValue is int) {
            _actualTripId = idValue;
          } else if (idValue is String) {
            _actualTripId = int.tryParse(idValue);
          } else {
            debugPrint('❌ Invalid trip ID type: ${idValue.runtimeType}');
            _showError("Server returned invalid trip ID format");
            return;
          }

          if (_actualTripId != null && _actualTripId! > 0) {
            debugPrint('✅ Trip started successfully! Trip ID: $_actualTripId');
          } else {
            debugPrint('❌ Invalid or missing trip ID: $idValue');
            _showError("Failed to get valid trip ID from server");
            return;
          }
        } else {
          debugPrint('❌ No trip ID found in response. Available keys: ${tripData.keys.toList()}');
          _showError("Server did not return trip ID");
          return;
        }
      } catch (e) {
        debugPrint('❌ Failed to start trip via API: $e');
        if (widget.tripId > 0) {
          _actualTripId = widget.tripId;
          debugPrint('⚠️ Using fallback trip ID from widget: $_actualTripId');
        } else {
          _showError("Failed to start trip: $e");
          return;
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

    debugPrint('🎯 GPS Update - Accuracy: ${position.accuracy.toStringAsFixed(1)}m, Raw Speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h');

    // ✅ Check if this is real movement or GPS noise
    final isRealMovement = _isRealMovement(position);

    double effectiveSpeed = 0.0;

    if (isRealMovement) {
      // Calculate smoothed speed from actual position changes
      effectiveSpeed = _calculateSmoothedSpeed(position);

      debugPrint('✅ Real movement detected! Speed: ${(effectiveSpeed * 3.6).toStringAsFixed(1)} km/h');

      // Check for significant movement for auto-end feature
      _checkForSignificantMovement(position);

      // Feed speed data to mode detector
      _modeDetector.addSpeedSample(effectiveSpeed, position.accuracy);

      // Calculate and add distance
      if (_currentPosition != null) {
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance / 1000; // Convert to km
        debugPrint('📏 Distance added: ${distance.toStringAsFixed(1)}m, Total: ${_totalDistance.toStringAsFixed(3)} km');
      }
    } else {
      // No real movement - feed zero speed to detector
      _modeDetector.addSpeedSample(0.0, position.accuracy);
      debugPrint('⏸️  No significant movement (GPS noise)');
    }

    // Get predicted mode
    final analysis = _modeDetector.getModeAnalysis();

    setState(() {
      _currentPosition = position;
      _currentSpeed = effectiveSpeed * 3.6; // Convert to km/h
      _detectedMode = analysis['predicted_mode'];
      _confidence = analysis['confidence'];

      // Only update route if real movement
      if (isRealMovement) {
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
      }
    });

    // Move camera to follow current position
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );

    // Send tracking point to backend (only if real movement)
    if (isRealMovement) {
      try {
        final apiService = context.read<ApiService>();

        if (apiService.accessToken == null || apiService.accessToken!.isEmpty) {
          await apiService.loadTokens();
        }

        final tripIdToUse = _actualTripId ?? widget.tripId;

        if (tripIdToUse <= 0) {
          debugPrint('⚠️ [LiveTracking] No valid trip ID available. Skipping tracking point.');
          return;
        }

        await apiService.addTrackingPoint(
          tripId: tripIdToUse,
          lat: position.latitude,
          lng: position.longitude,
          accuracy: position.accuracy,
          speed: effectiveSpeed,
        );
        debugPrint('✅ [LiveTracking] Tracking point sent successfully');
      } catch (e) {
        debugPrint('⚠️ Failed to send tracking point: $e');
      }
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

  IconData _getModeIcon(String mode) {
    if (mode.contains('Stationary') || mode.contains('Idle')) return Icons.pause_circle_outline;
    if (mode.contains('Walking')) return Icons.directions_walk;
    if (mode.contains('Bicycle')) return Icons.directions_bike;
    if (mode.contains('Motorcycle')) return Icons.two_wheeler;
    if (mode.contains('Car')) return Icons.directions_car;
    if (mode.contains('Bus') || mode.contains('Train')) return Icons.directions_bus;
    return Icons.help_outline;
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence) {
      case 'High':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
          _inactivityTimer?.cancel();
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
    // Calculate inactivity time
    final inactiveMinutes = _lastSignificantMovement != null
        ? DateTime.now().difference(_lastSignificantMovement!).inMinutes
        : 0;
    final showInactivityWarning = inactiveMinutes >= 3; // Warning at 3 mins

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Timer and Status Row
          Row(
            children: [
              const Icon(Icons.timer, color: Color(0xFF00adb5), size: 20),
              const SizedBox(width: 8),
              Text(
                _elapsedTime,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
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
                    Text(
                      _isTracking ? 'Tracking' : 'Paused',
                      style: const TextStyle(
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

          // Inactivity Warning
          if (showInactivityWarning) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No movement for $inactiveMinutes min. Trip will auto-end at 5 min.',
                      style: const TextStyle(color: Colors.orange, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Speed and Mode Detection Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Speed Section
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.speed, color: Color(0xFF00adb5), size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Speed',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currentSpeed.toStringAsFixed(1)} km/h',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(width: 1, height: 50, color: Colors.white.withOpacity(0.2)),

                // Mode Detection Section
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getModeIcon(_detectedMode),
                            color: const Color(0xFF00adb5),
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(_confidence).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getConfidenceColor(_confidence),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _confidence,
                              style: TextStyle(
                                fontSize: 9,
                                color: _getConfidenceColor(_confidence),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Travel Mode',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _detectedMode.split(' - ')[0],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Distance and Start Location Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${_totalDistance.toStringAsFixed(2)} km',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
              Expanded(
                flex: 2,
                child: _buildStatItem(
                  icon: Icons.location_city,
                  label: 'Start',
                  value: _isLoadingAddress
                      ? 'Loading...'
                      : (_startLocationAddress.length > 25
                      ? '${_startLocationAddress.substring(0, 25)}...'
                      : _startLocationAddress),
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
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEndTripButton() {
    return ElevatedButton(
      onPressed: _currentPosition == null ? null : () => _onEndTripPressed(),
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

  void _onEndTripPressed({bool autoEnded = false}) async {
    if (_currentPosition == null || _startPosition == null) {
      _showError("Cannot end trip: No location data");
      return;
    }



    setState(() => _isTracking = false);
    _positionSubscription?.cancel();
    _trackingTimer?.cancel();
    _inactivityTimer?.cancel();

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

      // Get final mode analysis
      final modeAnalysis = _modeDetector.getModeAnalysis();
      final detectedMode = modeAnalysis['predicted_mode'];

      debugPrint('🏁 Trip ended ${autoEnded ? "(AUTO)" : "(MANUAL)"}');
      debugPrint('📍 Start: $_startLocationAddress (${_startPosition!.latitude}, ${_startPosition!.longitude})');
      debugPrint('📍 End: $endAddress (${_currentPosition!.latitude}, ${_currentPosition!.longitude})');
      debugPrint('📊 Distance: ${_totalDistance.toStringAsFixed(2)} km');
      debugPrint('⏱️  Duration: ${DateTime.now().difference(_startTime!).inMinutes} min');
      debugPrint('🚗 Detected Mode: $detectedMode (Confidence: ${modeAnalysis['confidence']})');

      if (mounted) Navigator.pop(context);

      final tripIdToUse = _actualTripId ?? widget.tripId;

      if (tripIdToUse <= 0) {
        if (mounted) {
          Navigator.pop(context);
          _showError("Invalid trip ID. Cannot proceed.");
        }
        return;
      }

      debugPrint('🎯 Using trip ID for end form: $tripIdToUse');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TripEndFormScreen(
              tripId: tripIdToUse,
              startLocation: _startLocationAddress,
              startLat: _startPosition!.latitude,
              startLng: _startPosition!.longitude,
              endLat: _currentPosition!.latitude,
              endLng: _currentPosition!.longitude,
              endLocation: endAddress,
              distance: _totalDistance,
              duration: DateTime.now().difference(_startTime!).inMinutes,
              detectedMode: detectedMode,
              modeConfidence: modeAnalysis['confidence'],
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