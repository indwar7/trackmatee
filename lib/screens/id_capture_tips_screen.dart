import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'capture_id_screen.dart';

class IdCaptureTipsScreen extends StatelessWidget {
  const IdCaptureTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("ID Capture Guide", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Tip("Place ID on plain surface."),
            Tip("Ensure proper lighting."),
            Tip("Avoid glare / flashlight reflection."),
            Tip("Frame card edges fully."),
            SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
          onPressed: () => Get.to(() => const CaptureIdScreen(isFront: true)),
          child: const Text("Start Capturing", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

class Tip extends StatelessWidget {
  final String text;
  const Tip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 22),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }
}
