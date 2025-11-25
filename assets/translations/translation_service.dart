// lib/services/translation_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TranslationService {
  static final String? _apiKey = dotenv.env['google_translate_api_key'];
  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  static const Duration _httpTimeout = Duration(seconds: 10);

  /// Translate a single string using Google Translate API (v2)
  static Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      debugPrint('🌐 Translation requested: "$text" from $sourceLanguage to $targetLanguage');
      debugPrint('🌐 API Key exists: ${_apiKey != null && _apiKey!.isNotEmpty}');
      
      if (text.trim().isEmpty) return text;
      if (sourceLanguage == targetLanguage) return text;

      if (_apiKey == null || _apiKey!.isEmpty) {
        debugPrint('❌ TranslationService: API key is missing in .env file');
        debugPrint('❌ Make sure to add: google_translate_api_key=YOUR_KEY to your .env file');
        return text;
      }

      final uri = Uri.parse('$_baseUrl?key=$_apiKey');
      debugPrint('🌐 Sending translation request for "${text.length > 30 ? '${text.substring(0, 30)}...' : text}" from $sourceLanguage to $targetLanguage');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        }),
      ).timeout(
        _httpTimeout,
        onTimeout: () => throw TimeoutException('Translation request timed out after ${_httpTimeout.inSeconds} seconds'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final translatedText = jsonResponse['data']?['translations']?[0]?['translatedText'];
        
        if (translatedText is String && translatedText.isNotEmpty) {
          debugPrint('✅ Translation successful');
          return translatedText;
        } else {
          debugPrint('⚠️ Translation response format is invalid: ${response.body}');
          return text;
        }
      } else {
        debugPrint('❌ Translation failed with status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return text;
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Translation timed out: $e');
      return text;
    } on http.ClientException catch (e) {
      debugPrint('🌐 Network error during translation: $e');
      return text;
    } catch (e) {
      debugPrint('❌ Unexpected error in translateText: $e');
      return text;
    }
  }

  /// Batch translation (Google supports sending list)
  static Future<List<String>> translateBatch({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (texts.isEmpty) return texts;
    if (sourceLanguage == targetLanguage) return texts;

    try {
      if (_apiKey == null || _apiKey!.isEmpty) {
        debugPrint('TranslationService: API key missing in .env');
        return texts;
      }

      final uri = Uri.parse('$_baseUrl?key=$_apiKey');

      final resp = await http
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': texts,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        }),
      )
          .timeout(_httpTimeout);

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final trs = json['data']?['translations'] as List?;
        if (trs != null && trs.length == texts.length) {
          return trs.map((t) => t['translatedText'].toString()).toList();
        } else {
          // best-effort mapping: if API returns fewer, map what we have
          final list = (trs ?? []).map((t) => t['translatedText'].toString()).toList();
          // pad remainder with originals
          while (list.length < texts.length) list.add(texts[list.length]);
          return list;
        }
      } else {
        debugPrint(
            'TranslationService batch error ${resp.statusCode}: ${resp.body}');
        return texts;
      }
    } on Exception catch (e) {
      debugPrint('TranslationService batch exception: $e');
      return texts;
    }
  }
}
