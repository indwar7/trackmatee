import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  bool obscurePass = true;
  bool obscureConfirm = true;
  bool passFocused = false;
  bool loading = false;

  String? usernameError;
  String? emailError;
  String? passError;
  String? confirmError;

  // ---------------- VALIDATION ----------------

  void validateUsername() {
    final u = _username.text.trim();

    if (u.isEmpty) {
      setState(() => usernameError = null);
      return;
    }

    // at least 3 char, one letter, one special, no spaces
    final valid = RegExp(r'^(?=.*[A-Za-z])(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z0-9!@#$%^&*(),.?":{}|<>]{3,}$')
        .hasMatch(u);

    setState(() {
      usernameError = valid ? null : "Enter a valid User Name.";
    });
  }

  void validateEmail() {
    final email = _email.text.trim();

    if (email.isEmpty) {
      setState(() => emailError = null);
      return;
    }

    final valid =
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    setState(() => emailError = valid ? null : "Invalid email address");
  }

  bool isStrongPassword(String p) {
    return p.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(p) &&
        RegExp(r'[a-z]').hasMatch(p) &&
        RegExp(r'[0-9]').hasMatch(p) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(p);
  }

  void validatePassword() {
    final p = _pass.text;

    setState(() {
      passError = isStrongPassword(p) ? null : "Weak password";

      if (_confirm.text.isNotEmpty) {
        confirmError = p == _confirm.text ? null : "Passwords do not match";
      }
    });
  }

  void validateConfirm() {
    setState(() {
      confirmError =
      _pass.text == _confirm.text ? null : "Passwords do not match";
    });
  }

  bool get isFormValid =>
      usernameError == null &&
          emailError == null &&
          passError == null &&
          confirmError == null &&
          _username.text.trim().isNotEmpty &&
          _email.text.trim().isNotEmpty &&
          _pass.text.isNotEmpty &&
          _confirm.text.isNotEmpty;

  // ---------------- UI HELPERS ----------------

  Widget rule(bool ok, String text) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.circle_outlined,
          color: ok ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: ok ? Colors.white : Colors.grey[400],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ---------------- API: SIGNUP ----------------

  Future<void> _signup() async {
    if (!isFormValid) return;

    setState(() => loading = true);

    final email = _email.text.trim();
    final username = _username.text.trim();
    final password = _pass.text;

    try {
      final response = await http.post(
        Uri.parse("http://56.228.42.249/api/auth/signup/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "username": username,
          "password": password,
        }),
      );

      setState(() => loading = false);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar(
          "Success",
          "User registered successfully. OTP sent to email.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Go to OTP screen with email
        Get.toNamed('/phone-otp', arguments: email);
      } else {
        String message = "Signup failed";
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body["message"] != null) {
            message = body["message"].toString();
          }
        } catch (_) {}
        Get.snackbar(
          "Error",
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => loading = false);
      Get.snackbar(
        "Error",
        "Network error: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Sign up",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ---------------- USERNAME ----------------
            const Text("User Name",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _username,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => validateUsername(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF16213E),
                hintText: "Enter user name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: usernameError == null
                        ? Colors.transparent
                        : Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: usernameError == null
                        ? const Color(0xFF8B5CF6)
                        : Colors.red,
                    width: 2,
                  ),
                ),
              ),
            ),
            if (usernameError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  usernameError!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            const SizedBox(height: 24),

            // ---------------- EMAIL ----------------
            const Text("Email",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => validateEmail(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF16213E),
                hintText: "Enter email address",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: emailError == null
                        ? Colors.transparent
                        : Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: emailError == null
                        ? const Color(0xFF8B5CF6)
                        : Colors.red,
                    width: 2,
                  ),
                ),
              ),
            ),
            if (emailError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  emailError!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            const SizedBox(height: 24),

            // ---------------- PASSWORD ----------------
            const Text("Password",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),

            Focus(
              onFocusChange: (f) => setState(() => passFocused = f),
              child: TextField(
                controller: _pass,
                obscureText: obscurePass,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => validatePassword(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF16213E),
                  hintText: "Confirm your Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => obscurePass = !obscurePass),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: passError == null
                          ? Colors.transparent
                          : Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: passError == null
                          ? const Color(0xFF8B5CF6)
                          : Colors.red,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            if (passFocused) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rule(_pass.text.length >= 8, "At least 8 characters"),
                    rule(RegExp(r'[A-Z]').hasMatch(_pass.text),
                        "1 uppercase letter"),
                    rule(RegExp(r'[a-z]').hasMatch(_pass.text),
                        "1 lowercase letter"),
                    rule(RegExp(r'[0-9]').hasMatch(_pass.text), "1 number"),
                    rule(
                      RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                          .hasMatch(_pass.text),
                      "1 special character",
                    ),
                  ],
                ),
              ),
            ],

            if (passError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  passError!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            const SizedBox(height: 24),

            // ---------------- CONFIRM ----------------
            const Text("Confirm Password",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirm,
              obscureText: obscureConfirm,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => validateConfirm(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF16213E),
                hintText: "Confirm your Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => obscureConfirm = !obscureConfirm),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: confirmError == null
                        ? Colors.transparent
                        : Colors.red,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: confirmError == null
                        ? const Color(0xFF8B5CF6)
                        : Colors.red,
                    width: 2,
                  ),
                ),
              ),
            ),
            if (confirmError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  confirmError!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),

            const SizedBox(height: 40),

            // ---------------- BUTTON ----------------
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isFormValid && !loading ? _signup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid
                      ? const Color(0xFF8B5CF6)
                      : Colors.grey[700],
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
