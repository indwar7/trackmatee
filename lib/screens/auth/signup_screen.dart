// 📌 lib/screens/auth/signup_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  bool loading = false;

  String? userError;
  String? emailError;
  String? passError;
  String? confirmError;

  bool obscurePass = true;
  bool obscureConfirm = true;

  // ================= VALIDATION =================

  void validateUser() {
    setState(() {
      userError = _username.text.trim().length < 3 ? "Enter valid User Name." : null;
    });
  }

  void validateEmail() {
    setState(() {
      emailError = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email.text.trim())
          ? null
          : "Enter valid Email.";
    });
  }

  void validatePassword() {
    String p = _pass.text;
    bool strong = p.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(p) &&
        RegExp(r'[a-z]').hasMatch(p) &&
        RegExp(r'[0-9]').hasMatch(p) &&
        RegExp(r'[!@#\$&*~%^()\[\]{}?<>+=]').hasMatch(p);

    setState(() => passError = strong ? null : "Weak Password");
    validateConfirm();
  }

  void validateConfirm() {
    setState(() {
      confirmError = _pass.text == _confirm.text ? null : "Passwords do not match";
    });
  }

  bool get isValid =>
      userError == null &&
          emailError == null &&
          passError == null &&
          confirmError == null &&
          _username.text.isNotEmpty &&
          _email.text.isNotEmpty &&
          _pass.text.isNotEmpty &&
          _confirm.text.isNotEmpty;

  // ================= API CALL =================

  Future<void> signupUser() async {
    if (!isValid) return;

    setState(() => loading = true);

    final res = await http.post(
      Uri.parse("http://56.228.42.249/api/auth/signup/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _username.text.trim(),
        "email": _email.text.trim(),
        "password": _pass.text.trim()
      }),
    );

    setState(() => loading = false);

    if (res.statusCode == 200 || res.statusCode == 201) {
      Get.snackbar("Success", "OTP sent to email",
          backgroundColor: Colors.green, colorText: Colors.white);

      /// go to OTP screen
      Get.toNamed('/phone-otp', arguments: _email.text.trim());
    } else {
      Get.snackbar("Signup Failed", res.body.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ================= UI =================

  Widget textField({
    required TextEditingController c,
    required String label,
    required String hint,
    String? error,
    bool obscure = false,
    VoidCallback? toggle,
    Function(String)? onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          obscureText: obscure,
          onChanged: onChange,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xff2d2d3a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
            ),
            suffixIcon: toggle != null
                ? GestureDetector(
                onTap: toggle,
                child: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70))
                : null,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 18)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff191a2b),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text("Sign up",
            style: TextStyle(color: Colors.white, fontSize: 22)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textField(
                c: _username,
                label: "User Name",
                hint: "Enter user name",
                error: userError,
                onChange: (_) => validateUser()),

            textField(
                c: _email,
                label: "Email",
                hint: "Enter email address",
                error: emailError,
                onChange: (_) => validateEmail()),

            textField(
                c: _pass,
                label: "Password",
                hint: "Enter password",
                error: passError,
                obscure: obscurePass,
                toggle: () => setState(() => obscurePass = !obscurePass),
                onChange: (_) => validatePassword()),

            textField(
                c: _confirm,
                label: "Confirm Password",
                hint: "Re-enter password",
                error: confirmError,
                obscure: obscureConfirm,
                toggle: () => setState(() => obscureConfirm = !obscureConfirm),
                onChange: (_) => validateConfirm()),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isValid ? signupUser : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isValid ? Colors.deepPurpleAccent : Colors.grey[700],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign up",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () => Get.toNamed('/login'),
                child: const Text("Already a member? Log in",
                    style: TextStyle(color: Colors.white70)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
