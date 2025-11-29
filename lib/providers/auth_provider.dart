import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _phoneNumber;
  String? _email;
  bool _isVerified = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String? get userId => _userId;
  String? get phoneNumber => _phoneNumber;
  String? get email => _email;
  bool get isVerified => _isVerified;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userId != null && _isVerified;

  // Login with phone
  Future<void> loginWithPhone(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Call your auth API
      _phoneNumber = phoneNumber;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp, String verificationType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Call your OTP verification API
      _isVerified = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set user data after verification
  void setUserData({
    required String userId,
    required String email,
  }) {
    _userId = userId;
    _email = email;
    notifyListeners();
  }

  // Logout
  void logout() {
    _userId = null;
    _phoneNumber = null;
    _email = null;
    _isVerified = false;
    _errorMessage = null;
    notifyListeners();
  }
}
