import 'package:flutter/foundation.dart';  // REQUIRED for ChangeNotifier + notifyListeners

class IdCaptureProvider with ChangeNotifier {
  String? _capturedImagePath;
  bool _isProcessing = false;
  String? _processingError;
  Map<String, String>? _extractedData;

  String? get capturedImagePath => _capturedImagePath;
  bool get isProcessing => _isProcessing;
  String? get processingError => _processingError;
  Map<String, String>? get extractedData => _extractedData;

  Future<void> captureImage(String imagePath) async {
    _capturedImagePath = imagePath;
    notifyListeners();
  }

  Future<bool> processImage(String userId) async {
    _isProcessing = true;
    _processingError = null;
    notifyListeners();

    try {
      // TODO: Call OCR/Processing API
      _extractedData = {
        'documentNumber': 'XXXX1234',
        'name': 'John Doe',
        'dateOfBirth': '01-01-1990',
      };
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _processingError = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _capturedImagePath = null;
    _extractedData = null;
    _processingError = null;
    _isProcessing = false;
    notifyListeners();
  }
}