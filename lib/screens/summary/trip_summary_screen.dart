import 'package:flutter/material.dart';

class TripSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trip Summary")),
      body: Center(child: Text("Summary of your trip")),
    );
  }
}
