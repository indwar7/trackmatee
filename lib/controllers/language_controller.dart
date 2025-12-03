import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Language {
  final String code;
  final String name;

  Language({required this.code, required this.name});
}

class LanguageController extends GetxController {
  var currentLang = 'en'.obs;
  final _storage = GetStorage();

  List<Language> supportedLanguages = [
    Language(code: 'hi', name: 'Hindi'),
    Language(code: 'pa', name: 'Punjabi'),
    Language(code: 'bn', name: 'Bengali'),
    Language(code: 'ml', name: 'Malayalam'),
    Language(code: 'kn', name: 'Kannada'),
    Language(code: 'mr', name: 'Marathi'),
    Language(code: 'ta', name: 'Tamil'),
    Language(code: 'te', name: 'Telugu'),
    Language(code: 'en', name: 'English'),
  ];

  @override
  void onInit() {
    super.onInit();
    // Load saved language preference
    final savedLang = _storage.read('language');
    if (savedLang != null) {
      currentLang.value = savedLang;
    }
  }

  void changeLanguage(String langCode) {
    currentLang.value = langCode;
    _storage.write('language', langCode);
    Get.updateLocale(Locale(langCode));
  }

  String getCurrentLanguage() {
    return currentLang.value;
  }

  Language? getLanguageByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  // Translation method with proper implementation
  Future<String> translate(String text) async {
    try {
      // If you're using GetX translations, use this:
      // return text.tr;

      // For now, returning the original text as placeholder
      // TODO: Implement your translation logic here
      // You can integrate with translation APIs like Google Translate, or use local translation files

      return text;
    } catch (e) {
      debugPrint('Translation error: $e');
      return text;
    }
  }

  // Alternative: Synchronous translation method using GetX
  String translateSync(String key) {
    return key.tr;
  }
}