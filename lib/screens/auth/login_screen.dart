import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool passwordVisible = false;
  bool isLoading = false;

  String? emailError;
  String? passwordError;

  bool hasMinLength = false;
  bool hasUpper = false;
  bool hasLower = false;
  bool hasDigit = false;
  bool hasSpecial = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final pwd = passwordController.text;
    setState(() {
      hasMinLength = pwd.length >= 8;
      hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
      hasLower = RegExp(r'[a-z]').hasMatch(pwd);
      hasDigit = RegExp(r'[0-9]').hasMatch(pwd);
      hasSpecial = RegExp(r'[!@#\$&*~%^()\[\]{}?<>|/+_=.,-]').hasMatch(pwd);
    });
  }

  bool isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  bool isPasswordStrong() => hasMinLength && hasUpper && hasLower && hasDigit && hasSpecial;

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!isValidEmail(email)) {
      setState(() => emailError = "Invalid email format");
      return;
    }

    if (!isPasswordStrong()) {
      setState(() => passwordError = "Enter valid password");
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("http://56.228.42.249/api/auth/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Get.snackbar("Success", "Login Successful",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed('/home');
    } else {
      Get.snackbar("Login Failed", "Email or Password is incorrect",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _reqRow(bool satisfied, String text) => Row(
    children: [
      Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: satisfied ? Colors.green : Colors.transparent,
          border: Border.all(color: satisfied ? Colors.green : Colors.white24),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          satisfied ? Icons.check : Icons.circle,
          size: satisfied ? 14 : 8,
          color: satisfied ? Colors.white : Colors.white24,
        ),
      ),
      const SizedBox(width: 10),
      Text(text,
          style: TextStyle(
            fontSize: 13,
            color: satisfied ? Colors.white : Colors.white70,
          )),
    ],
  );

  @override
  Widget build(BuildContext context) {
    const fieldFill = Color(0xFF3A3A3A);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Log in",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 40),

            /// EMAIL
            const Text("Email", style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your Email",
                filled: true,
                fillColor: fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: emailError != null
                      ? const BorderSide(color: Colors.red)
                      : BorderSide.none,
                ),
              ),
            ),
            if (emailError != null)
              Text(emailError!, style: const TextStyle(color: Colors.redAccent)),

            const SizedBox(height: 24),

            /// PASSWORD
            const Text("Password", style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: !passwordVisible,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your Password",
                filled: true,
                fillColor: fieldFill,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => passwordVisible = !passwordVisible),
                  child: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: passwordError != null
                      ? const BorderSide(color: Colors.red)
                      : BorderSide.none,
                ),
              ),
            ),
            if (passwordError != null)
              Text(passwordError!, style: const TextStyle(color: Colors.redAccent)),

            const SizedBox(height: 16),

            /// PASSWORD CONDITIONS
            _reqRow(hasMinLength, "At least 8 characters"),
            _reqRow(hasUpper, "1 uppercase letter"),
            _reqRow(hasLower, "1 lowercase letter"),
            _reqRow(hasDigit, "1 number"),
            _reqRow(hasSpecial, "1 special character"),

            const SizedBox(height: 20),

            /// 🔥 ADDING YOUR REQUESTED SECTION HERE
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Get.toNamed('/forgot-password'),
                child: const Text("Forgot password?",
                    style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 14)),
              ),
            ),

            const SizedBox(height: 30),

            /// LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loginUser,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/signup"),
                child: const Text.rich(TextSpan(children: [
                  TextSpan(text: "Don’t have an account? ", style: TextStyle(color: Colors.white70)),
                  TextSpan(text: "Register Instead", style: TextStyle(color: Color(0xFF8B5CF6)))
                ])),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
