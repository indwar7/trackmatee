import 'package:flutter/material.dart';
import '../../models/enum_trip_mode.dart';
import '../summary/trip_summary_screen.dart';

class PlannedTripFormScreen extends StatelessWidget {
  final TripMode mode;
  PlannedTripFormScreen({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Plan a Trip")),
      body: Center(
        child: ElevatedButton(
          child: Text("Save Plan"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TripSummaryScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
