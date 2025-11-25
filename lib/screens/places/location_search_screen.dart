import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// ---------- CONFIG: your chosen API key (you provided this)
const String kPlacesApiKey = 'AIzaSyCvuze7W6e4S_5bSAEuX9K0GJCPMvvVNTQ';

// ---------- NOTE: screenshot local path (you uploaded this)
const String uploadedScreenshotPath = '/mnt/data/Screenshot 2025-11-23 at 5.16.20 PM.png';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({Key? key}) : super(key: key);

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> _predictions = [];
  Timer? _debounce;
  String? _sessionToken;

  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // create a session token for Places Autocomplete (helps billing & quality)
    _sessionToken = UniqueKey().toString();
    // autofocus the text field when screen opens and open keyboard:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String input) {
    // debounce so we don't spam Google on every keystroke
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (input.trim().isNotEmpty) {
        _fetchAutocomplete(input.trim());
      } else {
        setState(() {
          _predictions = [];
        });
      }
    });
  }

  Future<void> _fetchAutocomplete(String input) async {
    setState(() {
      _loading = true;
      _error = '';
    });

    // Limit Autocomplete to India using components=country:in
    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
      'input': input,
      'key': kPlacesApiKey,
      'components': 'country:in',
      // optional: restrict to regions/cities with types, but types are restricted by Google
      'types': '(regions)', // this returns cities, states, localities often
      'sessiontoken': _sessionToken,
      'strictbounds': 'false'
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          setState(() {
            _predictions = data['predictions'] ?? [];
            _loading = false;
          });
        } else {
          setState(() {
            _error = data['status'] ?? 'Unknown error';
            _predictions = [];
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'HTTP ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _selectPrediction(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id'] as String?;
    final description = prediction['description'] as String? ?? prediction['structured_formatting']?['main_text'] ?? '';

    if (placeId == null) {
      // fallback: return description only
      Get.back(result: {'description': description});
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    // Use Place Details to get coordinates and formatted address
    final detailsUri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'fields': 'formatted_address,geometry,name,place_id',
      'key': kPlacesApiKey,
      'sessiontoken': _sessionToken,
    });

    try {
      final response = await http.get(detailsUri);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'OK' && body['result'] != null) {
          final result = body['result'];
          final formatted = result['formatted_address'] as String? ?? description;
          final geometry = result['geometry'] ?? {};
          final location = geometry['location'] ?? {};
          final lat = (location['lat'] is num) ? (location['lat'] as num).toDouble() : null;
          final lng = (location['lng'] is num) ? (location['lng'] as num).toDouble() : null;

          // Build result map (HomeScreenBody expects at least 'description')
          final Map<String, dynamic> returned = {
            'description': formatted,
            'place_id': result['place_id'] ?? placeId,
            'lat': lat,
            'lng': lng,
            'formatted_address': formatted,
          };

          // Return to previous screen with the selected result
          Get.back(result: returned);
          return;
        } else {
          setState(() {
            _error = body['status'] ?? 'Place Details failed';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'HTTP ${response.statusCode} (details)';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }

    // if we couldn't get details, fallback to returning description only
    Get.back(result: {'description': description, 'place_id': placeId});
  }

  Widget _buildPredictionTile(Map<String, dynamic> p) {
    final main = p['structured_formatting']?['main_text'] ?? p['description'] ?? '';
    final secondary = p['structured_formatting']?['secondary_text'] ?? '';

    return ListTile(
      leading: const Icon(Icons.location_on_outlined),
      title: Text(main),
      subtitle: secondary.isNotEmpty ? Text(secondary) : null,
      onTap: () => _selectPrediction(p),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 8,
        title: Row(
          children: [
            const Icon(Icons.search, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search city, locality or landmark',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: _onQueryChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: (text) {
                  // If user hits search without selecting a suggestion, just return the typed text
                  if (text.trim().isNotEmpty && _predictions.isEmpty) {
                    Get.back(result: {'description': text.trim()});
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _predictions = [];
                });
                FocusScope.of(context).requestFocus(_focusNode);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_loading)
            LinearProgressIndicator(
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
            ),
          if (_error.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.redAccent.withOpacity(0.15),
              padding: const EdgeInsets.all(8),
              child: Text(
                _error,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          Expanded(
            child: _predictions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      return _buildPredictionTile(_predictions[index] as Map<String, dynamic>);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.location_on, color: Colors.white70),
          title: const Text('Use current location', style: TextStyle(color: Colors.white)),
          onTap: () {
            // Optionally: implement device location / permission flow
            // For now, we return a placeholder description
            Get.back(result: {'description': 'Current location'});
          },
        ),
        const Divider(color: Colors.white12),
        // show the uploaded screenshot path for developer reference
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Screenshot (dev): $uploadedScreenshotPath',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: Text('Start typing to search locations in India', style: TextStyle(color: Colors.white54))),
      ],
    );
  }
}
