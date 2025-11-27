import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationInput extends StatefulWidget {
  final Function(LatLng) onDestinationSelected;

  const DestinationInput({
    super.key,
    required this.onDestinationSelected,
  });

  @override
  State<DestinationInput> createState() => _DestinationInputState();
}

class _DestinationInputState extends State<DestinationInput> {
  final TextEditingController _controller = TextEditingController();

  LatLng dummyPlaceConvert(String text) {
    // ⚠️ IMPORTANT:
    // Replace this with Google Places API later.
    // For now it returns a random location for testing.
    return LatLng(28.6139, 77.2090); // Delhi (Test)
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: "Enter destination",
          contentPadding: EdgeInsets.all(15),
          suffixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (value) {
          LatLng dest = dummyPlaceConvert(value);
          widget.onDestinationSelected(dest);
        },
      ),
    );
  }
}
