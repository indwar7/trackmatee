import 'package:flutter/material.dart';

class TripFormScreen extends StatefulWidget {
  final String startAddress;
  final double startLat;
  final double startLng;
  final String destAddress;
  final double destLat;
  final double destLng;
  final double distance;

  const TripFormScreen({
    super.key,
    required this.startAddress,
    required this.startLat,
    required this.startLng,
    required this.destAddress,
    required this.destLat,
    required this.destLng,
    required this.distance,
  });

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController tripNameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController companionsController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  String selectedVehicle = "Car";
  final List<String> vehicles = ["Car", "Bike", "Bus", "Train", "Flight"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Trip Details"),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildCard(
                title: "Trip Info",
                child: Column(
                  children: [
                    buildTextField("Trip Name", tripNameController),
                    const SizedBox(height: 12),
                    buildTextField("Description", descController, maxLines: 3),
                  ],
                ),
              ),
              buildCard(
                title: "Locations & Distance",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoText("Start: ${widget.startAddress}"),
                    infoText("Destination: ${widget.destAddress}"),
                    infoText("Distance: ${widget.distance.toStringAsFixed(2)} km"),
                  ],
                ),
              ),
              buildCard(
                title: "Vehicle & Budget",
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      value: selectedVehicle,
                      items: vehicles
                          .map((v) => DropdownMenuItem(
                          value: v, child: Text(v, style: const TextStyle(color: Colors.white))))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedVehicle = val!;
                        });
                      },
                      dropdownColor: const Color(0xFF1F1F1F),
                      decoration: InputDecoration(
                        labelText: "Vehicle Type",
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildTextField(
                      "Estimated Budget (₹)",
                      budgetController,
                      inputType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              buildCard(
                title: "Additional Details",
                child: Column(
                  children: [
                    buildTextField(
                        "Companions (comma separated)", companionsController),
                    const SizedBox(height: 12),
                    buildTextField("Notes", notesController, maxLines: 3),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Trip Saved Successfully!")),
                    );
                  }
                },
                child: const Text(
                  "Save Trip",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black38,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "This field cannot be empty";
        return null;
      },
    );
  }

  Widget infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white70),
      ),
    );
  }
}
