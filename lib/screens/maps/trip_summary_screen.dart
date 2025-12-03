import 'package:flutter/material.dart';

class TripSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const TripSummaryScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final trip = data;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Summary"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            summaryTile("Start Location", trip["startLocation"]?.toString() ?? "N/A"),
            summaryTile("End Location", trip["endLocation"]?.toString() ?? "N/A"),
            summaryTile("Start Time", trip["startTime"]?.toString() ?? "N/A"),
            summaryTile("End Time", trip["endTime"]?.toString() ?? "N/A"),
            summaryTile("Distance (km)", trip["distance"]?.toString() ?? "N/A"),
            summaryTile("Fuel Type", trip["fuelType"]?.toString() ?? "N/A"),
            summaryTile("Fuel Cost", trip["fuelCost"]?.toString() ?? "N/A"),
            summaryTile("Toll Cost", trip["tollCost"]?.toString() ?? "N/A"),
            summaryTile("Parking Cost", trip["parkingCost"]?.toString() ?? "N/A"),
            summaryTile("Total Trip Cost", trip["totalCost"]?.toString() ?? "N/A"),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Back",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}