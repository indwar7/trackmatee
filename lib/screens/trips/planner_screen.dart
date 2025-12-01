import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();

  List<String> suggestions = ["Delhi NCR", "New Delhi", "Dehradun", "Dwarka", "Dewas"];
  bool selectingStart = true; // toggles between start/destination
  List<String> filteredList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xff0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Choose start point",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔹 START LOCATION FIELD
            GestureDetector(
              onTap: () => setState(() => selectingStart = true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Start", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    TextField(
                      controller: fromController,
                      onChanged: (val) => _filter(val),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Pickup Location",
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// 🔹 DESTINATION FIELD
            GestureDetector(
              onTap: () => setState(() => selectingStart = false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Destination", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    TextField(
                      controller: toController,
                      onChanged: (val) => _filter(val),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Drop Location",
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// 🔹 Set on Map
            Row(
              children: const [
                Icon(Icons.pin_drop_outlined, color: Colors.deepPurple, size: 22),
                SizedBox(width: 6),
                Text("Set on map", style: TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 SUGGESTIONS DROPDOWN (UI from screenshot)
            if (filteredList.isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      if (selectingStart) {
                        fromController.text = filteredList[i];
                      } else {
                        toController.text = filteredList[i];
                      }
                      setState(() => filteredList.clear());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        filteredList[i],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),

            const Spacer(),

            /// 🔹 DONE BUTTON (Same as UI)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (fromController.text.isEmpty || toController.text.isEmpty) {
                    Get.snackbar("Missing fields", "Please enter both locations",
                        backgroundColor: Colors.deepPurple, colorText: Colors.white);
                    return;
                  }

                  Get.snackbar("Done ✔", "Trip from ${fromController.text} to ${toController.text} set",
                      backgroundColor: Colors.deepPurple, colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8A4FFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Done", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// suggestion list update
  void _filter(String text) {
    if (text.isEmpty) {
      setState(() => filteredList.clear());
      return;
    }
    setState(() {
      filteredList = suggestions
          .where((e) => e.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }
}
