import 'package:flutter/foundation.dart';

class VerificationProvider with ChangeNotifier {
  bool _aadharVerified = false;
  bool _panVerified = false;
  bool _bankAccountVerified = false;
  bool _isVerifying = false;
  String? _verificationError;

  bool get aadharVerified => _aadharVerified;
  bool get panVerified => _panVerified;
  bool get bankAccountVerified => _bankAccountVerified;
  bool get isVerifying => _isVerifying;
  bool get allVerified => _aadharVerified && _panVerified && _bankAccountVerified;

  Future<bool> verifyAadhar(String aadharNumber, String userId) async {
    _isVerifying = true;
    _verificationError = null;
    notifyListeners();

    try {
      // TODO: Call Aadhar verification API
      _aadharVerified = true;
      _isVerifying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _verificationError = e.toString();
      _isVerifying = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyPan(String panNumber, String userId) async {
    _isVerifying = true;
    _verificationError = null;
    notifyListeners();

    try {
      // TODO: Call PAN verification API
      _panVerified = true;
      _isVerifying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _verificationError = e.toString();
      _isVerifying = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyBankAccount(String accountNumber, String userId) async {
    _isVerifying = true;
    _verificationError = null;
    notifyListeners();

    try {
      // TODO: Call Bank verification API
      _bankAccountVerified = true;
      _isVerifying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _verificationError = e.toString();
      _isVerifying = false;
      notifyListeners();
      return false;
    }
  }
}
