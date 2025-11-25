import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({Key? key}) : super(key: key);

  @override
  _PhoneOtpScreenState createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;
  bool _loading = false;
  String? _errorMessage;

  // 🔥 Replace these URLs with your Django backend
  final String sendOtpUrl = "http://YOUR_DJANGO_URL/api/send_otp/";
  final String verifyOtpUrl = "http://YOUR_DJANGO_URL/api/verify_otp/";

  Future<void> _sendOtp() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    String phone = _phoneController.text.trim();

    if (phone.isEmpty || !RegExp(r'^\+?\d{10,15}$').hasMatch(phone)) {
      setState(() {
        _loading = false;
        _errorMessage = "Enter a valid phone number with country code";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(sendOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _otpSent = true;
        });
        _showMessage("OTP sent to $phone");
      } else {
        setState(() {
          _errorMessage = "Failed to send OTP. Try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Check connection.";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    String phone = _phoneController.text.trim();
    String otp = _otpController.text.trim();

    if (otp.length != 6) {
      setState(() {
        _loading = false;
        _errorMessage = "Enter a valid 6-digit OTP";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(verifyOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      if (response.statusCode == 200) {
        _showMessage("Phone verified successfully!");

        Navigator.pushReplacementNamed(
          context,
          '/otp-verification',
          arguments: phone,
        );
      } else {
        setState(() {
          _errorMessage = "Invalid OTP. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Check connection.";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Phone Number Verification',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: '+911234567890',
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_otpSent ? 'Resend OTP' : 'Send OTP'),
              ),

              if (_otpSent) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter OTP',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF16213E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _loading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify OTP'),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
