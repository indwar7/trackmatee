import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IdStatusScreen extends StatelessWidget {
  final bool approved;
  final String message;

  const IdStatusScreen({
    super.key,
    this.approved = false,
    this.message = "Verification is under review",
  });

  @override
  Widget build(BuildContext context) {        // <--- MUST RETURN WIDGET
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        title: const Text("Verification Status"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              approved ? Icons.verified : Icons.hourglass_top_rounded,
              size: 95,
              color: approved ? Colors.green : Colors.amber,
            ),

            const SizedBox(height: 25),

            Text(
              approved ? "Verified Successfully!" : "Pending Verification",
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: ()=> Get.offAllNamed('/home'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED)),
              child: const Text("Continue", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
