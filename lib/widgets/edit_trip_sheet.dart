import 'package:flutter/material.dart';

class EditTripSheet extends StatefulWidget {
  final Map<String, dynamic> trip;
  final Function(Map<String, dynamic>) onSave;

  const EditTripSheet({
    super.key,
    required this.trip,
    required this.onSave,
  });

  @override
  State<EditTripSheet> createState() => _EditTripSheetState();
}

class _EditTripSheetState extends State<EditTripSheet> {
  late TextEditingController modeCtrl;
  late TextEditingController purposeCtrl;
  late TextEditingController companionCtrl;
  late TextEditingController fuelCtrl;
  late TextEditingController parkingCtrl;
  late TextEditingController tollCtrl;
  late TextEditingController ticketCtrl;

  @override
  void initState() {
    super.initState();

    modeCtrl = TextEditingController(text: widget.trip['mode_of_travel']);
    purposeCtrl = TextEditingController(text: widget.trip['trip_purpose']);
    companionCtrl =
        TextEditingController(text: widget.trip['number_of_companions']?.toString() ?? '0');
    fuelCtrl = TextEditingController(text: widget.trip['fuel_expense']?.toString() ?? '');
    parkingCtrl = TextEditingController(text: widget.trip['parking_cost']?.toString() ?? '');
    tollCtrl = TextEditingController(text: widget.trip['toll_cost']?.toString() ?? '');
    ticketCtrl = TextEditingController(text: widget.trip['ticket_cost']?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Edit Manual Trip",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            _field("Mode", modeCtrl),
            _field("Purpose", purposeCtrl),
            _field("Companions", companionCtrl),
            _field("Fuel Expense", fuelCtrl),
            _field("Parking Cost", parkingCtrl),
            _field("Toll Cost", tollCtrl),
            _field("Ticket Cost", ticketCtrl),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  widget.onSave({
                    "mode_of_travel": modeCtrl.text,
                    "trip_purpose": purposeCtrl.text,
                    "number_of_companions":
                    int.tryParse(companionCtrl.text) ?? 0,
                    "fuel_expense": double.tryParse(fuelCtrl.text),
                    "parking_cost": double.tryParse(parkingCtrl.text),
                    "toll_cost": double.tryParse(tollCtrl.text),
                    "ticket_cost": double.tryParse(ticketCtrl.text),
                  });
                },
                child: const Text("Save Changes"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
