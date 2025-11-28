import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();

  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();

  // Cost controllers
  TextEditingController parkingController = TextEditingController(text: "0");
  TextEditingController tollController = TextEditingController(text: "0");
  double fuelCost = 0;
  double totalCost = 0;

  LatLng? startLatLng;
  LatLng? endLatLng;

  bool selectingStart = false;
  bool selectingEnd = false;

  String startTime = "";
  String endTime = "";
  String date = "";
  String duration = "";
  double distance = 0.0;

  bool showForm = false;

  // Dropdowns
  String? travelMode;
  String? purpose;
  String? fuelType;

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    await Geolocator.requestPermission();
  }

  Future<void> searchPlace(String text, bool isStart) async {
    if (text.isEmpty) return;
    try {
      List<Location> locations = await locationFromAddress(text);
      if (locations.isNotEmpty) {
        LatLng target = LatLng(locations.first.latitude, locations.first.longitude);

        GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(target, 15));

        setState(() {
          if (isStart) {
            startLatLng = target;
            markers.add(Marker(markerId: MarkerId("start"), position: target));
          } else {
            endLatLng = target;
            markers.add(Marker(markerId: MarkerId("end"), position: target));
          }
        });
      }
    } catch (e) {
      print("Search error: $e");
    }
  }

  // After clicking "Done" below End Location
  void generateForm() {
    if (startLatLng == null || endLatLng == null) return;

    calculateDistance();
    autoFillTime();
    calculateFuelCost();
    calculateTotalCost();

    setState(() {
      showForm = true;
    });
  }

  void autoFillTime() {
    DateTime now = DateTime.now();
    startTime = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    endTime = "${(now.hour + 1) % 24}:${now.minute.toString().padLeft(2, '0')}";
    date = "${now.day}/${now.month}/${now.year}";
    duration = "1 hour";
  }

  void calculateDistance() {
    const R = 6371;
    double lat1 = startLatLng!.latitude * pi / 180;
    double lat2 = endLatLng!.latitude * pi / 180;
    double dLat = (endLatLng!.latitude - startLatLng!.latitude) * pi / 180;
    double dLon = (endLatLng!.longitude - startLatLng!.longitude) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    distance = 6371 * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  void calculateFuelCost() {
    if (fuelType == null) return;

    double rate = 0;
    if (fuelType == "Petrol") rate = 102;
    if (fuelType == "Diesel") rate = 90;
    if (fuelType == "EV") rate = 12; // per kWh approx

    fuelCost = distance * (rate / 15); // avg 15 km/l mileage
  }

  void calculateTotalCost() {
    double parking = double.tryParse(parkingController.text) ?? 0;
    double toll = double.tryParse(tollController.text) ?? 0;

    totalCost = fuelCost + parking + toll;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Planned Trip"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: LatLng(28.61, 77.20), zoom: 12),
            markers: markers,
            onTap: (pos) {
              if (selectingStart) {
                startLatLng = pos;
                startController.text = "${pos.latitude}, ${pos.longitude}";
                selectingStart = false;
              } else if (selectingEnd) {
                endLatLng = pos;
                endController.text = "${pos.latitude}, ${pos.longitude}";
                selectingEnd = false;
              }
              setState(() {});
            },
            onMapCreated: (c) => _controller.complete(c),
          ),

          // ===================== TOP INPUT BOXES =====================
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                bigInputBox(
                  label: "Start Location",
                  controller: startController,
                  onChanged: (v) => searchPlace(v, true),
                  onPick: () {
                    selectingStart = true;
                  },
                ),
                const SizedBox(height: 10),
                bigInputBox(
                  label: "End Location",
                  controller: endController,
                  onChanged: (v) => searchPlace(v, false),
                  onPick: () {
                    selectingEnd = true;
                  },
                ),

                // DONE BUTTON to open form
                if (startLatLng != null && endLatLng != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: StadiumBorder(),
                      ),
                      onPressed: generateForm,
                      child: const Text("Done"),
                    ),
                  )
              ],
            ),
          ),

          // ======================= FORM =============================
          if (showForm)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 500,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20))),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      formField("Start Location", startController.text),
                      formField("End Location", endController.text),
                      formField("Start time", startTime),
                      formField("End time", endTime),
                      formField("Day/Date", date),
                      formField("Duration", duration),
                      formField("Distance", "${distance.toStringAsFixed(2)} km"),

                      dropdownBox(
                        label: "Mode of Travel",
                        value: travelMode,
                        items: ["Car", "Bike", "Bus", "Walk"],
                        onChanged: (v) => setState(() => travelMode = v),
                      ),

                      dropdownBox(
                        label: "Fuel Type",
                        value: fuelType,
                        items: ["Petrol", "Diesel", "EV"],
                        onChanged: (v) {
                          setState(() {
                            fuelType = v;
                            calculateFuelCost();
                            calculateTotalCost();
                          });
                        },
                      ),

                      // Parking Cost
                      costInput("Parking Cost (₹)", parkingController),

                      // Toll Cost
                      costInput("Toll Cost (₹)", tollController),

                      // Fuel Cost auto
                      formField("Fuel Cost", "₹${fuelCost.toStringAsFixed(2)}"),

                      // Total Cost auto
                      formField("Total Trip Cost",
                          "₹${totalCost.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget costInput(String label, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        onChanged: (v) => calculateTotalCost(),
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget formField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Text(
        "$label: $value",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget dropdownBox({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<String>(
        dropdownColor: Colors.black,
        isExpanded: true,
        value: value,
        underline: SizedBox(),
        hint: Text(label, style: TextStyle(color: Colors.white54)),
        items: items
            .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: TextStyle(color: Colors.white))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget bigInputBox({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required VoidCallback onPick,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.purple),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration:
              InputDecoration(hintText: label, border: InputBorder.none),
            ),
          ),
          IconButton(
              onPressed: onPick,
              icon: Icon(Icons.map, color: Colors.purple))
        ],
      ),
    );
  }
}
