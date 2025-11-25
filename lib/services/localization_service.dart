import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const defaultLocale = Locale('en');
  
  // Fallback locale
  static const fallbackLocale = Locale('en');
  
  // Supported languages
  static final Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिंदी',
    'pa': 'ਪੰਜਾਬੀ',
    'bn': 'বাংলা',
    'ml': 'മലയാളം',
    'kn': 'ಕನ್ನಡ',
    'mr': 'मराठी',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'ru': 'Русский',
    'zh': '中文',
  };

  // Translations
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {},
    'hi': {},
    'pa': {},
    'bn': {},
    'ml': {},
    'kn': {},
    'mr': {},
    'ta': {},
    'te': {},
    'de': {},
    'es': {},
    'fr': {},
    'it': {},
    'ru': {},
    'zh': {},
  };

  // Initialize the localization service
  static Future<void> init() async {
    // Load all language files
    for (var lang in supportedLanguages.keys) {
      try {
        final jsonString = await rootBundle.loadString('assets/translations/translations_lang/$lang.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        
        // Convert all values to String
        _localizedValues[lang] = jsonMap.map((key, value) => 
            MapEntry(key, value.toString()));
      } catch (e) {
        print('Error loading $lang translations: $e');
      }
    }
  }

  // Get translation for a key
  static String getTranslatedValue(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ?? 
           _localizedValues[defaultLocale.languageCode]?[key] ?? 
           key; // Return the key if not found
  }

  @override
  Map<String, Map<String, String>> get keys => _localizedValues;

  // Get language name from code
  static String getLanguageName(String languageCode) {
    return supportedLanguages[languageCode] ?? languageCode;
  }

  // Get language code from name
  static String? getLanguageCode(String languageName) {
    return supportedLanguages.entries
        .firstWhere(
          (entry) => entry.value == languageName,
          orElse: () => const MapEntry('', ''),
        )
        .key;
  }
}
