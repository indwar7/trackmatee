import 'package:flutter/material.dart';

class TripReviewForm extends StatefulWidget {
  const TripReviewForm({super.key});

  @override
  State<TripReviewForm> createState() => _TripReviewFormState();
}

class _TripReviewFormState extends State<TripReviewForm> {
  // Text controllers
  final TextEditingController startLocation = TextEditingController();
  final TextEditingController endLocation = TextEditingController();
  final TextEditingController dayTime = TextEditingController();
  final TextEditingController duration = TextEditingController();
  final TextEditingController distance = TextEditingController();
  final TextEditingController costIncurred = TextEditingController();
  final TextEditingController parkingCost = TextEditingController();
  final TextEditingController tollCost = TextEditingController();
  final TextEditingController ticketCost = TextEditingController();

  // Dropdown values
  String? selectedFuelType;
  String? selectedModeOfTravel;
  String? selectedTripPurpose;

  // Dropdown lists
  final List<String> fuelTypes = ["Petrol", "Diesel", "Electric"];
  final List<String> modesOfTravel = [
    "Car",
    "Bike",
    "Bus",
    "Airplane",
    "Train",
    "Bi-cycle",
    "Walk"
  ];
  final List<String> tripPurposes = [
    "Family",
    "Office",
    "Daily commute (Home)",
    "Daily commute (Office)",
    "Vacation",
    "Friends trip",
    "Walk"
  ];

  Widget _buildTextBox(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownBox(
      String label, String? selectedValue, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                dropdownColor: const Color(0xFF374151),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                items: items
                    .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: const TextStyle(color: Colors.white)),
                ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),

      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Trip Review"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextBox("Start Location", startLocation),
            _buildTextBox("End Location", endLocation),
            _buildTextBox("Day/Time", dayTime),
            _buildTextBox("Duration", duration),
            _buildTextBox("Distance", distance),
            _buildTextBox("Cost Incurred", costIncurred),

            // DROPDOWNS ADDED HERE
            _buildDropdownBox(
              "Mode of Travel",
              selectedModeOfTravel,
              modesOfTravel,
                  (value) => setState(() => selectedModeOfTravel = value),
            ),

            _buildDropdownBox(
              "Trip Purpose",
              selectedTripPurpose,
              tripPurposes,
                  (value) => setState(() => selectedTripPurpose = value),
            ),

            _buildDropdownBox(
              "Fuel Type",
              selectedFuelType,
              fuelTypes,
                  (value) => setState(() => selectedFuelType = value),
            ),

            _buildTextBox("Parking Cost", parkingCost),
            _buildTextBox("Toll Cost", tollCost),
            _buildTextBox("Ticket Cost", ticketCost),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "- Check the entered times and duration of the trip\n"
                    "- Make sure distance and expenses are accurate\n"
                    "- Are you satisfied with your trip?",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
