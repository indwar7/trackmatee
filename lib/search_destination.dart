import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'config/keys.dart';

class SearchDestinationScreen extends StatefulWidget {
  const SearchDestinationScreen({super.key});

  @override
  State<SearchDestinationScreen> createState() =>
      _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Destination")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: _controller,
          googleAPIKey: AppKeys.mapsApiKey,
          inputDecoration: const InputDecoration(
            hintText: "Search destination",
            border: OutlineInputBorder(),
          ),
          debounceTime: 600,
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (prediction) {
            Navigator.pop(
              context,
              LatLng(
                double.parse(prediction.lat!),
                double.parse(prediction.lng!),
              ),
            );
          },
          itemClick: (prediction) {
            _controller.text = prediction.description ?? "";
          },
        ),
      ),
    );
  }
}
