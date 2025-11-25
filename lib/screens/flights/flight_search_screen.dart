import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({Key? key}) : super(key: key);

  @override
  _FlightSearchScreenState createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  String tripType = 'one-way';
  String fromCity = '';
  String toCity = '';
  DateTime? departureDate;
  DateTime? returnDate;
  int adults = 1;
  int children = 0;
  int infants = 0;
  String travelClass = 'Economy';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Flights'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Trip Type Selector
              _buildTripTypeSelector(),
              const SizedBox(height: 20),
              
              // From/To Fields
              _buildLocationFields(),
              const SizedBox(height: 16),
              
              // Date Selectors
              _buildDateSelectors(),
              const SizedBox(height: 16),
              
              // Travelers & Class
              _buildTravelerAndClass(),
              const SizedBox(height: 24),
              
              // Search Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _searchFlights,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SEARCH FLIGHTS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTripTypeOption('One Way', 'one-way'),
        _buildTripTypeOption('Round Trip', 'round-trip'),
        _buildTripTypeOption('Multi City', 'multi-city'),
      ],
    );
  }

  Widget _buildTripTypeOption(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => tripType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: tripType == value ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: tripType == value ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        // From Field
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'From',
            prefixIcon: Icon(Icons.flight_takeoff),
            border: OutlineInputBorder(),
          ),
          onTap: () {
            // TODO: Implement city selection
          },
          readOnly: true,
          controller: TextEditingController(text: fromCity),
        ),
        const SizedBox(height: 12),
        
        // To Field
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'To',
            prefixIcon: Icon(Icons.flight_land),
            border: OutlineInputBorder(),
          ),
          onTap: () {
            // TODO: Implement city selection
          },
          readOnly: true,
          controller: TextEditingController(text: toCity),
        ),
      ],
    );
  }

  Widget _buildDateSelectors() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Departure',
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              suffixText: departureDate != null
                  ? DateFormat('MMM dd, yyyy').format(departureDate!)
                  : null,
            ),
            readOnly: true,
            onTap: () => _selectDate(context, isDeparture: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Return',
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              suffixText: returnDate != null
                  ? DateFormat('MMM dd, yyyy').format(returnDate!)
                  : 'Optional',
              enabled: tripType == 'round-trip',
            ),
            readOnly: true,
            onTap: tripType == 'round-trip'
                ? () => _selectDate(context, isDeparture: false)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTravelerAndClass() {
    return Row(
      children: [
        // Travelers
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Travelers',
              prefixIcon: const Icon(Icons.people),
              border: const OutlineInputBorder(),
              suffixText: '$adults Adult${adults != 1 ? 's' : ''}${children > 0 ? ', $children Child${children != 1 ? 'ren' : ''}' : ''}${infants > 0 ? ', $infants Infant${infants != 1 ? 's' : ''}' : ''}',
            ),
            readOnly: true,
            onTap: _showTravelerDialog,
          ),
        ),
        const SizedBox(width: 16),
        // Class
        Expanded(
          child: DropdownButtonFormField<String>(
            value: travelClass,
            decoration: const InputDecoration(
              labelText: 'Class',
              border: OutlineInputBorder(),
            ),
            items: ['Economy', 'Premium Economy', 'Business', 'First Class']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => travelClass = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isDeparture}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          departureDate = picked;
          // If return date is before departure date, reset it
          if (returnDate != null && returnDate!.isBefore(picked)) {
            returnDate = null;
          }
        } else {
          returnDate = picked;
        }
      });
    }
  }

  void _showTravelerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTravelerCounter(
                    'Adults',
                    '12+ years',
                    adults,
                    (value) => setState(() => adults = value),
                  ),
                  const Divider(),
                  _buildTravelerCounter(
                    'Children',
                    '2-12 years',
                    children,
                    (value) => setState(() => children = value),
                  ),
                  const Divider(),
                  _buildTravelerCounter(
                    'Infants',
                    '0-2 years',
                    infants,
                    (value) => setState(() => infants = value),
                    max: adults,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('DONE'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTravelerCounter(
    String title,
    String subtitle,
    int value,
    Function(int) onChanged, {
    int max = 9,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Text('$value'),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  void _searchFlights() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement flight search
      debugPrint('Searching flights...');
      debugPrint('From: $fromCity');
      debugPrint('To: $toCity');
      debugPrint('Departure: $departureDate');
      debugPrint('Return: $returnDate');
      debugPrint('Travelers: $adults Adults, $children Children, $infants Infants');
      debugPrint('Class: $travelClass');
      
      // Navigate to flight results screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => FlightResultsScreen(
      //       fromCity: fromCity,
      //       toCity: toCity,
      //       departureDate: departureDate!,
      //       returnDate: returnDate,
      //       adults: adults,
      //       children: children,
      //       infants: infants,
      //       travelClass: travelClass,
      //     ),
      //   ),
      // );
    }
  }
}
