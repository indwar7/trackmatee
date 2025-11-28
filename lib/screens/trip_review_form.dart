import 'package:flutter/material.dart';

class TripFormScreen extends StatefulWidget {
  final String startLocation;
  final String endLocation;

  const TripFormScreen({
    super.key,
    required this.startLocation,
    required this.endLocation,
  });

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  String? mode;
  String? fuel;
  String? purpose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Form")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildReadOnlyBox("Start Location", widget.startLocation),
            const SizedBox(height: 20),
            _buildReadOnlyBox("End Location", widget.endLocation),
            const SizedBox(height: 20),

            // Mode of travel
            DropdownButtonFormField(
              decoration: _inputDecoration("Mode of Travel"),
              items: ["Car", "Bike", "Bus", "Train", "Walk"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => mode = v),
            ),
            const SizedBox(height: 20),

            // Fuel type
            DropdownButtonFormField(
              decoration: _inputDecoration("Fuel Type"),
              items: ["Petrol", "Diesel", "Electric"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => fuel = v),
            ),
            const SizedBox(height: 20),

            // Purpose
            DropdownButtonFormField(
              decoration: _inputDecoration("Trip Purpose"),
              items: [
                "Family",
                "Office",
                "Daily commute (Home)",
                "Daily commute (Office)",
                "Vacation",
                "Friends trip",
                "Walk"
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => purpose = v),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {},
              child: const Text("Done"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
