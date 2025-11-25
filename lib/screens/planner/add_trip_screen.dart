import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({Key? key}) : super(key: key);

  @override
  _AddTripScreenState createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _startFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();

  List<String> _suggestions = [];
  final List<String> _mockLocations = [
    'Delhi NCR', 'New Delhi', 'Dehradun', 'Dwarka', 'Mumbai', 'Bangalore'
  ];

  @override
  void initState() {
    super.initState();
    _startFocus.addListener(() => setState(() {}));
    _destinationFocus.addListener(() => setState(() {}));
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() {
      _suggestions = _mockLocations
          .where((loc) => loc.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required FocusNode focusNode,
      required String hint,
      required IconData icon}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: _onSearchChanged,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
    );
  }
  
  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: _suggestions.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_suggestions[index], style: GoogleFonts.inter(color: Colors.white)),
          onTap: () {
            if (_startFocus.hasFocus) {
              _startController.text = _suggestions[index];
            } else if (_destinationFocus.hasFocus) {
              _destinationController.text = _suggestions[index];
            }
            setState(() => _suggestions = []);
            FocusScope.of(context).unfocus();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Choose Route',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _startController,
              focusNode: _startFocus,
              hint: 'Pickup Location',
              icon: Icons.trip_origin,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _destinationController,
              focusNode: _destinationFocus,
              hint: 'Drop Location',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 20),
            if (_suggestions.isNotEmpty && (_startFocus.hasFocus || _destinationFocus.hasFocus))
              Expanded(child: _buildSuggestionsList()),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Done action
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Done', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
