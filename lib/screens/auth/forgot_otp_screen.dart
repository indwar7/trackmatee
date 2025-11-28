// lib/screens/auth/forgot_otp_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotOtpVerifyScreen extends StatefulWidget {
  const ForgotOtpVerifyScreen({super.key});

  @override
  State<ForgotOtpVerifyScreen> createState() => _ForgotOtpVerifyScreenState();
}

class _ForgotOtpVerifyScreenState extends State<ForgotOtpVerifyScreen> {
  final List<TextEditingController> otp = List.generate(6, (_) => TextEditingController());

  int seconds = 30;
  Timer? timer;

  String getOtp() => otp.map((e) => e.text).join();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var c in otp) { c.dispose(); }
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  // When user clicks VERIFY
  void verifyOtp() {
    if (getOtp().length != 6) {
      Get.snackbar("Invalid OTP", "OTP must be 6 digits",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    /// Navigate to reset password (API will run there)
    Get.toNamed('/reset-password', arguments: {
      "email": Get.arguments,
      "otp": getOtp(),
    });
  }

  /// OTP box UI
  Widget otpBox(int index) {
    return SizedBox(
      width: 46,
      height: 52,
      child: TextField(
        controller: otp[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,

        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),

        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color(0xFF3A3A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),

        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments ?? "your email";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("Enter verification code",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),
            Text(
              "Please enter the verification code we have sent to\n$email",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 35),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => otpBox(i)),
            ),

            const SizedBox(height: 15),
            Text("$seconds seconds left",
                style: const TextStyle(color: Colors.white54, fontSize: 13)),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Verify OTP",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 25),

            Center(
              child: GestureDetector(
                onTap: () {
                  seconds = 30;
                  startTimer(); // resend UI only — resend API can be added later
                },
                child: const Text("Resend Code",
                    style: TextStyle(fontSize: 15, color: Color(0xFF8B5CF6))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
