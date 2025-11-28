import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  final String? apiKey = dotenv.env['places_api_key'];

  Future<List<dynamic>> getAutocomplete(String input) async {
    if (apiKey == null) {
      print('ERROR: places_api_key not found in .env file');
      return [];
    }

    final String url = 
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'OK') {
          return jsonResponse['predictions'] as List<dynamic>;
        }
      }
    } catch (e) {
      print('Error fetching autocomplete results: $e');
    }
    return [];
  }
}
