import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/screens/places/location_search_screen.dart';
import 'package:intl/intl.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  String? _fromAddress;
  String? _toAddress;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'planner'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationTile(
              icon: Icons.location_on,
              label: 'from'.tr,
              address: _fromAddress ?? 'search_location'.tr,
              onTap: () async {
                final result = await Get.to(() => const LocationSearchScreen());
                if (result != null) {
                  setState(() {
                    _fromAddress = result['description'];
                  });
                }
              },
            ),
            const Divider(color: Colors.white24),
            _buildLocationTile(
              icon: Icons.flag,
              label: 'to'.tr,
              address: _toAddress ?? 'search_location'.tr,
              onTap: () async {
                final result = await Get.to(() => const LocationSearchScreen());
                if (result != null) {
                  setState(() {
                    _toAddress = result['description'];
                  });
                }
              },
            ),
            const Divider(color: Colors.white24),
            _buildDateTimeTile(
              icon: Icons.calendar_today,
              label: 'date'.tr,
              value: _selectedDate == null
                  ? 'select_date'.tr
                  : DateFormat.yMMMd().format(_selectedDate!),
              onTap: () => _selectDate(context),
            ),
            const Divider(color: Colors.white24),
            _buildDateTimeTile(
              icon: Icons.access_time,
              label: 'time'.tr,
              value: _selectedTime == null
                  ? 'select_time'.tr
                  : _selectedTime!.format(context),
              onTap: () => _selectTime(context),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'trip_scheduled'.tr,
                  'your_trip_from'.tr + (_fromAddress ?? '') + 'to'.tr + (_toAddress ?? '') + 'has_been_scheduled'.tr,
                   snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                'schedule_ride'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile({
    required IconData icon,
    required String label,
    required String address,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      subtitle: Text(address, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDateTimeTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
