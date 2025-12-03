import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

import 'live_tracking_screen.dart';
import 'manual_trip_screen.dart';
import 'planned_trip_screen.dart';
import 'trip_history_screen.dart';
import 'map_screen.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCheckingTrip = true;
  int? _ongoingTripId;
  String? _ongoingTripStart;

  @override
  void initState() {
    super.initState();
    _checkOngoingTrip();
  }

  Future<void> _checkOngoingTrip() async {
    final api = context.read<ApiService>();

    // Check if there's an ongoing trip
    if (api.authToken == null || api.authToken!.isEmpty) {
      setState(() => _isCheckingTrip = false);
      return;
    }

    try {
      final ongoing = await api.getOngoingTrip();

      if (ongoing != null && mounted) {
        // Extract trip ID
        int? extractedId;
        if (ongoing['id'] is int) extractedId = ongoing['id'];
        if (ongoing['id'] is String) extractedId = int.tryParse(ongoing['id']);

        if (extractedId == null && ongoing['trip'] != null) {
          final t = ongoing['trip'];
          if (t['id'] is int) extractedId = t['id'];
          if (t['id'] is String) extractedId = int.tryParse(t['id']);
        }

        // Check if active
        bool isActive = false;
        if (ongoing['status'] is String) {
          final s = ongoing['status'].toLowerCase();
          if (s == "ongoing" || s == "active" || s == "in_progress") {
            isActive = true;
          }
        }
        if (ongoing['is_active'] == true) isActive = true;

        if (isActive && extractedId != null) {
          setState(() {
            _ongoingTripId = extractedId;
            _ongoingTripStart = ongoing['start_location_name'] ??
                ongoing['start_location'] ??
                "Unknown";
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking ongoing trip: $e");
    }

    if (mounted) {
      setState(() => _isCheckingTrip = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingTrip) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("TrackMate"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.location_on, size: 80, color: Color(0xFF00adb5)),
              const SizedBox(height: 20),
              const Text(
                'Track Your Journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Show Resume button if ongoing trip exists
              if (_ongoingTripId != null) ...[
                _buildResumeButton(),
                const SizedBox(height: 16),
              ],

              _buildMenuButton(
                icon: Icons.play_circle_fill,
                title: _ongoingTripId != null ? "Start New Trip" : "Start Trip",
                subtitle: _ongoingTripId != null
                    ? "End current trip first"
                    : "Begin live tracking",
                color: const Color(0xFF00adb5),
                onTap: _ongoingTripId != null ? null : _startTrip,
              ),
              const SizedBox(height: 16),

              _buildMenuButton(
                icon: Icons.edit_location_alt,
                title: "Save Untracked Trip",
                subtitle: "Add trip manually",
                color: const Color(0xFFe94560),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManualTripScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuButton(
                icon: Icons.schedule,
                title: "Plan a Trip",
                subtitle: "Schedule future trips",
                color: const Color(0xFFf39c12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlannedTripScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuButton(
                icon: Icons.history,
                title: "Trip History",
                subtitle: "View past trips",
                color: const Color(0xFF8e44ad),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TripHistoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // NEW: Map Button
              _buildMenuButton(
                icon: Icons.map,
                title: "Map",
                subtitle: "View and search locations",
                color: const Color(0xFF27ae60),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumeButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf39c12).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFf39c12)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFf39c12)),
              SizedBox(width: 8),
              Text(
                'You have an ongoing trip',
                style: TextStyle(
                  color: Color(0xFFf39c12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveTrackingScreen(
                    tripId: _ongoingTripId!,
                    startLocation: _ongoingTripStart ?? "Unknown",
                  ),
                ),
              ).then((_) => _checkOngoingTrip());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf39c12),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Resume Trip'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF16213e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    )
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.4),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startTrip() async {
    try {
      bool ok = await LocationService.checkPermissions();
      if (!ok) {
        _showError("Location permission denied");
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final pos = await LocationService.getCurrentLocation();
      final address = await LocationService.getAddressFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      final api = context.read<ApiService>();
      final res = await api.startTrip(
        startLat: pos.latitude,
        startLng: pos.longitude,
        locationName: address,
      );

      if (mounted) Navigator.pop(context);

      final id = res["trip"]?["id"];
      int? safeId;
      if (id is int) safeId = id;
      if (id is String) safeId = int.tryParse(id);

      if (safeId == null) {
        throw Exception("Invalid trip ID received");
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveTrackingScreen(
              tripId: safeId!,
              startLocation: address,
            ),
          ),
        ).then((_) => _checkOngoingTrip());
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showError("Failed to start trip: $e");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }
}