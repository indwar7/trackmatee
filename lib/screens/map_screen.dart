
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'trip_review_form.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
const MapScreen({Key? key}) : super(key: key);

@override
State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
GoogleMapController? _mapController;
Position? _currentPosition;
bool _isTracking = false;
bool _hasPermission = false;
String _startLocation = 'Current Location';
String _destination = '';
final List<LatLng> _routePoints = [];
final Set<Polyline> _polylines = {};
final Set<Marker> _markers = {};
StreamSubscription<Position>? _positionStreamSubscription;
final TextEditingController _destController = TextEditingController();

@override
void initState() {
super.initState();
_requestLocationPermission();
}

@override
void dispose() {
_positionStreamSubscription?.cancel();
_mapController?.dispose();
_destController.dispose();
super.dispose();
}

Future<void> _requestLocationPermission() async {
final status = await Permission.location.request();

if (status.isGranted) {
setState(() => _hasPermission = true);
await _getCurrentLocation();
} else if (status.isDenied) {
_showPermissionDialog();
} else if (status.isPermanentlyDenied) {
openAppSettings();
}
}

Future<void> _getCurrentLocation() async {
try {
Position position = await Geolocator.getCurrentPosition(
desiredAccuracy: LocationAccuracy.high,
);

setState(() {
_currentPosition = position;
_markers.add(
Marker(
markerId: const MarkerId('current'),
position: LatLng(position.latitude, position.longitude),
icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
),
);
});

_mapController?.animateCamera(
CameraUpdate.newCameraPosition(
CameraPosition(
target: LatLng(position.latitude, position.longitude),
zoom: 15,
),
),
);
} catch (e) {
_showErrorDialog('Error getting location: $e');
}
}

void _startLiveTracking() {
if (!_hasPermission) {
_requestLocationPermission();
return;
}

setState(() {
_isTracking = true;
_routePoints.clear();
});

const locationSettings = LocationSettings(
accuracy: LocationAccuracy.high,
distanceFilter: 5,
);

_positionStreamSubscription = Geolocator.getPositionStream(
locationSettings: locationSettings,
).listen((Position position) {
final newPoint = LatLng(position.latitude, position.longitude);

setState(() {
_currentPosition = position;
_routePoints.add(newPoint);

_markers.clear();
_markers.add(
Marker(
markerId: const MarkerId('current'),
position: newPoint,
icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
rotation: position.heading,
),
);

if (_routePoints.length > 1) {
_polylines.clear();
_polylines.add(
Polyline(
polylineId: const PolylineId('route'),
points: _routePoints,
color: Colors.purple,
width: 5,
patterns: [PatternItem.dash(20), PatternItem.gap(10)],
),
);
}
});

_mapController?.animateCamera(
CameraUpdate.newLatLng(newPoint),
);
});
}

void _stopTracking() {
_positionStreamSubscription?.cancel();
setState(() => _isTracking = false);
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const TripReviewForm()),
);
}

void _showPermissionDialog() {
showDialog(
context: context,
builder: (context) => AlertDialog(
backgroundColor: const Color(0xFF374151),
title: const Text('Location Permission Required'),
content: const Text(
'This app needs location access to track your movement. Please grant location permission.',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
Navigator.pop(context);
_requestLocationPermission();
},
style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
child: const Text('Grant Permission'),
),
],
),
);
}

void _showErrorDialog(String message) {
showDialog(
context: context,
builder: (context) => AlertDialog(
backgroundColor: const Color(0xFF374151),
title: const Text('Error'),
content: Text(message),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('OK'),
),
],
),
);
}

void _showDestinationInput() {
showModalBottomSheet(
context: context,
backgroundColor: const Color(0xFF1F2937),
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
),
builder: (context) => Padding(
padding: EdgeInsets.only(
bottom: MediaQuery.of(context).viewInsets.bottom,
left: 16,
right: 16,
top: 16,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text(
'Enter Destination',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
IconButton(
onPressed: () => Navigator.pop(context),
icon: const Icon(Icons.close, color: Colors.white),
),
],
),
const SizedBox(height: 16),
TextField(
controller: _destController,
style: const TextStyle(color: Colors.white),
decoration: InputDecoration(
hintText: 'Enter destination address',
hintStyle: TextStyle(color: Colors.grey[400]),
filled: true,
fillColor: const Color(0xFF374151),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: BorderSide.none,
),
prefixIcon: const Icon(Icons.search, color: Colors.grey),
),
),
const SizedBox(height: 16),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () {
setState(() {
_destination = _destController.text;
});
Navigator.pop(context);
_startLiveTracking();
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.purple,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
),
child: const Text(
'Confirm',
style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
),
),
const SizedBox(height: 16),
],
),
),
);
}

@override
Widget build(BuildContext context) {
if (!_hasPermission) {
return Scaffold(
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.location_off, size: 64, color: Colors.purple),
const SizedBox(height: 16),
const Text(
'Location Access Required',
style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
const Padding(
padding: EdgeInsets.symmetric(horizontal: 32),
child: Text(
'Please enable location access to use this app',
textAlign: TextAlign.center,
style: TextStyle(color: Colors.grey),
),
),
const SizedBox(height: 24),
ElevatedButton(
onPressed: _requestLocationPermission,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.purple,
padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
),
child: const Text('Enable Location'),
),
],
),
),
);
}

return Scaffold(
body: Stack(
children: [
_currentPosition == null
? const Center(child: CircularProgressIndicator())
    : GoogleMap(
initialCameraPosition: CameraPosition(
target: LatLng(
_currentPosition!.latitude,
_currentPosition!.longitude,
),
zoom: 15,
),
onMapCreated: (controller) => _mapController = controller,
markers: _markers,
polylines: _polylines,
myLocationEnabled: false,
myLocationButtonEnabled: false,
zoomControlsEnabled: false,
mapType: MapType.normal,
),
Positioned(
top: 0,
left: 0,
right: 0,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
child: SafeArea(
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: const [
Text(
'20:09',
style: TextStyle(color: Colors.white, fontSize: 14),
),
Row(
children: [
Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.white),
SizedBox(width: 4),
Icon(Icons.wifi, size: 16, color: Colors.white),
SizedBox(width: 4),
Icon(Icons.battery_full, size: 16, color: Colors.white),
],
),
],
),
),
),
),
Positioned(
top: 48,
left: 16,
child: SafeArea(
child: Container(
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.3),
shape: BoxShape.circle,
),
child: IconButton(
onPressed: () {},
icon: const Icon(Icons.arrow_back, color: Colors.white),
),
),
),
),
Positioned(
top: 48,
left: 64,
right: 16,
child: SafeArea(
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.3),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Text(
_startLocation,
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.black,
fontWeight: FontWeight.w500,
fontSize: 16,
),
),
),
),
),
if (_isTracking)
Positioned(
top: 120,
left: 0,
right: 0,
child: Center(
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
decoration: BoxDecoration(
color: Colors.green,
borderRadius: BorderRadius.circular(25),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.3),
blurRadius: 10,
),
],
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 8,
height: 8,
decoration: const BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
),
),
const SizedBox(width: 8),
const Text(
'Live Tracking Active',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
fontSize: 14,
),
),
],
),
),
),
),
Positioned(
bottom: 32,
left: 16,
right: 16,
child: Row(
children: [
Expanded(
child: ElevatedButton(
onPressed: _isTracking ? _stopTracking : _startLiveTracking,
style: ElevatedButton.styleFrom(
backgroundColor: _isTracking ? Colors.red : Colors.purple,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(25),
),
elevation: 8,
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(_isTracking ? Icons.stop : Icons.play_arrow),
const SizedBox(width: 8),
Text(
_isTracking ? 'Stop Tracking' : 'Start',
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
],
),
),
),
if (!_isTracking) ...[
const SizedBox(width: 12),
Container(
decoration: BoxDecoration(
color: const Color(0xFF374151),
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.3),
blurRadius: 10,
),
],
),
child: IconButton(
onPressed: _showDestinationInput,
icon: const Icon(Icons.location_on, color: Colors.white),
iconSize: 28,
),
),
],
],
),
),
Positioned(
bottom: 120,
right: 16,
child: Container(
decoration: BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.3),
blurRadius: 10,
),
],
),
child: IconButton(
onPressed: () {
if (_currentPosition != null) {
_mapController?.animateCamera(
CameraUpdate.newLatLng(
LatLng(
_currentPosition!.latitude,
_currentPosition!.longitude,
),
),
);
}
},
icon: const Icon(Icons.my_location, color: Colors.black),
),
),
),
],
),
);
}
}
