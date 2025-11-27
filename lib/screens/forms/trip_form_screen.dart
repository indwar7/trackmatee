import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripFormScreen extends StatefulWidget {
  final List<dynamic> polyPoints;
  final double distance;
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final String modeOfTravel; // optional default

  const TripFormScreen({
    super.key,
    required this.polyPoints,
    required this.distance,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    this.modeOfTravel = "Car",
  });

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  // Dropdowns
  String? tripPurpose;
  String? fuelType;
  String? modeOfTravel;

  // Cost controllers
  final parkingCostController = TextEditingController();
  final tollCostController = TextEditingController();
  final totalCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    modeOfTravel = widget.modeOfTravel;
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.endTime.difference(widget.startTime);
    final co2Emission = (widget.distance * 0.12).toStringAsFixed(2); // rough estimate in kg

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Details"),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------- AUTO-FILLED READ-ONLY FIELDS -----------------
            _buildReadOnlyField("Start Location", widget.startLocation),
            const SizedBox(height: 10),
            _buildReadOnlyField("End Location", widget.endLocation),
            const SizedBox(height: 10),
            _buildReadOnlyField(
                "Start Time", DateFormat('hh:mm a').format(widget.startTime)),
            const SizedBox(height: 10),
            _buildReadOnlyField(
                "End Time", DateFormat('hh:mm a').format(widget.endTime)),
            const SizedBox(height: 10),
            _buildReadOnlyField(
                "Date", DateFormat('yyyy-MM-dd').format(widget.startTime)),
            const SizedBox(height: 10),
            _buildReadOnlyField(
                "Duration", "${duration.inHours}h ${duration.inMinutes % 60}m"),
            const SizedBox(height: 10),
            _buildReadOnlyField(
                "Distance Travelled", "${widget.distance.toStringAsFixed(2)} km"),
            const SizedBox(height: 10),
            _buildReadOnlyField("CO₂ Emission", "$co2Emission kg"),
            const SizedBox(height: 20),

            // ----------------- DROPDOWNS -----------------
            const Text("Trip Purpose"),
            const SizedBox(height: 5),
            DropdownButtonFormField(
              decoration: _inputDecoration("Select Purpose"),
              value: tripPurpose,
              items: const [
                DropdownMenuItem(value: "Work", child: Text("Work")),
                DropdownMenuItem(value: "Personal", child: Text("Personal")),
                DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
                DropdownMenuItem(value: "Travel", child: Text("Travel")),
              ],
              onChanged: (val) => setState(() => tripPurpose = val),
            ),
            const SizedBox(height: 20),

            const Text("Mode of Travel"),
            const SizedBox(height: 5),
            DropdownButtonFormField(
              decoration: _inputDecoration("Select Mode"),
              value: modeOfTravel,
              items: const [
                DropdownMenuItem(value: "Car", child: Text("Car")),
                DropdownMenuItem(value: "Bike", child: Text("Bike")),
                DropdownMenuItem(value: "Bus", child: Text("Bus")),
                DropdownMenuItem(value: "Train", child: Text("Train")),
                DropdownMenuItem(value: "Walk", child: Text("Walk")),
              ],
              onChanged: (val) => setState(() => modeOfTravel = val),
            ),
            const SizedBox(height: 20),

            const Text("Fuel Type"),
            const SizedBox(height: 5),
            DropdownButtonFormField(
              decoration: _inputDecoration("Select Fuel Type"),
              value: fuelType,
              items: const [
                DropdownMenuItem(value: "Petrol", child: Text("Petrol")),
                DropdownMenuItem(value: "Diesel", child: Text("Diesel")),
                DropdownMenuItem(value: "CNG", child: Text("CNG")),
                DropdownMenuItem(value: "Electric", child: Text("Electric")),
              ],
              onChanged: (val) => setState(() => fuelType = val),
            ),
            const SizedBox(height: 20),

            // ----------------- COST FIELDS -----------------
            const Text("Parking Cost"),
            const SizedBox(height: 5),
            TextField(
              controller: parkingCostController,
              decoration: _inputDecoration("Enter Parking Cost"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            const Text("Toll Cost"),
            const SizedBox(height: 5),
            TextField(
              controller: tollCostController,
              decoration: _inputDecoration("Enter Toll Cost"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            const Text("Total Trip Cost"),
            const SizedBox(height: 5),
            TextField(
              controller: totalCostController,
              decoration: _inputDecoration("Enter Total Cost"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),

            // ----------------- SAVE BUTTON -----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: const Text("Save Trip"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: value,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _submit() {
    if (tripPurpose == null || fuelType == null || modeOfTravel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all dropdowns")),
      );
      return;
    }

    // Collect trip data
    print("Trip Purpose: $tripPurpose");
    print("Mode of Travel: $modeOfTravel");
    print("Fuel Type: $fuelType");
    print("Parking Cost: ${parkingCostController.text}");
    print("Toll Cost: ${tollCostController.text}");
    print("Total Cost: ${totalCostController.text}");

    Navigator.pop(context);
  }
}
