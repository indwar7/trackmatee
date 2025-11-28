import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisible = false;
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

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isPasswordStrong() {
    return hasMinLength && hasUpper && hasLower && hasDigit && hasSpecial;
  }

  void validateAndLogin() {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    bool ok = true;

    if (!isValidEmail(email)) {
      emailError = "Invalid Email!";
      ok = false;
    }

    if (!isPasswordStrong()) {
      passwordError =
      "Password must be 8+ chars, include upper, lower, number & special.";
      ok = false;
    }

    setState(() {});

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful (demo).")),
      );
    }
  }

  Widget _reqRow(bool satisfied, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: satisfied ? const Color(0xFF4CAF50) : Colors.transparent,
            border: Border.all(
              color: satisfied ? const Color(0xFF4CAF50) : Colors.white24,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            satisfied ? Icons.check_rounded : Icons.circle,
            size: satisfied ? 14 : 8,
            color: satisfied ? Colors.white : Colors.white24,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontFamily: "Helvetica",
            color: satisfied ? Colors.white : Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const fieldFill = Color(0xFF3A3A3A);
    final hintStyle = TextStyle(color: Colors.grey[500], fontFamily: "Helvetica");

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Log in",
          style: TextStyle(
            fontFamily: "Helvetica",
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // EMAIL LABEL
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontFamily: "Helvetica",
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // EMAIL FIELD
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: "Helvetica"),
                        decoration: InputDecoration(
                          hintText: "Enter your Email",
                          hintStyle: hintStyle,
                          filled: true,
                          fillColor: fieldFill,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: emailError != null
                                ? const BorderSide(color: Colors.red, width: 1.4)
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: emailError != null
                                  ? Colors.red
                                  : const Color(0xFF8B5CF6),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      if (emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 6),
                          child: Text(
                            emailError!,
                            style: const TextStyle(
                              fontFamily: "Helvetica",
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // PASSWORD LABEL + FORGOT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontFamily: "Helvetica",
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, "/forgot-password"),
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                fontFamily: "Helvetica",
                                fontSize: 14,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // PASSWORD FIELD
                      TextField(
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: "Helvetica"),
                        decoration: InputDecoration(
                          hintText: "Enter your Password",
                          hintStyle: hintStyle,
                          filled: true,
                          fillColor: fieldFill,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: passwordError != null
                                ? const BorderSide(color: Colors.red, width: 1.4)
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: passwordError != null
                                  ? Colors.red
                                  : const Color(0xFF8B5CF6),
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () =>
                                setState(() => passwordVisible = !passwordVisible),
                            child: Icon(
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ),

                      if (passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 6),
                          child: Text(
                            passwordError!,
                            style: const TextStyle(
                              fontFamily: "Helvetica",
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // LIVE PASSWORD RULES
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _reqRow(hasMinLength, "At least 8 characters"),
                          const SizedBox(height: 10),
                          _reqRow(hasUpper, "1 uppercase letter"),
                          const SizedBox(height: 10),
                          _reqRow(hasLower, "1 lowercase letter"),
                          const SizedBox(height: 10),
                          _reqRow(hasDigit, "1 number"),
                          const SizedBox(height: 10),
                          _reqRow(hasSpecial, "1 special character"),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: validateAndLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontFamily: "Helvetica",
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, "/signup"),
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontFamily: "Helvetica",
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                children: [
                                  TextSpan(text: "Don’t have an account? "),
                                  TextSpan(
                                    text: "Register instead",
                                    style: TextStyle(
                                        color: Color(0xFF8B5CF6),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
