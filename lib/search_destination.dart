import 'package:flutter/material.dart';
import 'services/geocoding_service.dart';

class SearchDestinationScreen extends StatefulWidget {
  @override
  State<SearchDestinationScreen> createState() =>
      _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  final TextEditingController controller = TextEditingController();
  bool loading = false;

  Future<void> search() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() => loading = true);

    final result =
    await GeocodingService.getCoordinatesFromAddress(text);

    setState(() => loading = false);

    if (result != null) {
      Navigator.pop(context, result);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Address not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Destination"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter place",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: search,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Search"),
            )
          ],
        ),
      ),
    );
  }
}
