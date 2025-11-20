import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscureNew = true;
  bool obscureConfirm = true;

  // Password rule flags
  bool hasMinLength = false;
  bool hasUpper = false;
  bool hasLower = false;
  bool hasDigit = false;
  bool hasSpecial = false;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final pwd = newPasswordController.text;

    setState(() {
      hasMinLength = pwd.length >= 8;
      hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
      hasLower = RegExp(r'[a-z]').hasMatch(pwd);
      hasDigit = RegExp(r'[0-9]').hasMatch(pwd);
      hasSpecial = RegExp(r'[!@#\$&*~%^()\[\]{}?<>|/+_=.,-]').hasMatch(pwd);
    });
  }

  bool isPasswordStrong() {
    return hasMinLength && hasUpper && hasLower && hasDigit && hasSpecial;
  }

  void _onDone() {
    if (!isPasswordStrong()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("Password does not meet required conditions"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Widget reqRow(bool ok, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: ok ? const Color(0xFF4CAF50) : Colors.transparent,
            border: Border.all(
              color: ok ? const Color(0xFF4CAF50) : Colors.white24,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            ok ? Icons.check_rounded : Icons.circle,
            color: ok ? Colors.white : Colors.white24,
            size: ok ? 14 : 8,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontFamily: "Helvetica",
            color: ok ? Colors.white : Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const fieldColor = Color(0xFF16213E);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontFamily: "Helvetica",
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // NEW PASSWORD LABEL
                    const Text(
                      'New Password',
                      style: TextStyle(
                        fontFamily: "Helvetica",
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // NEW PASSWORD FIELD
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: "Helvetica"),
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: fieldColor,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF8B5CF6), width: 1.5),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() {
                            obscureNew = !obscureNew;
                          }),
                          child: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LIVE PASSWORD STRENGTH RULES
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reqRow(hasMinLength, "At least 8 characters"),
                        const SizedBox(height: 10),
                        reqRow(hasUpper, "1 uppercase letter"),
                        const SizedBox(height: 10),
                        reqRow(hasLower, "1 lowercase letter"),
                        const SizedBox(height: 10),
                        reqRow(hasDigit, "1 number"),
                        const SizedBox(height: 10),
                        reqRow(hasSpecial, "1 special character"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // CONFIRM PASSWORD LABEL
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontFamily: "Helvetica",
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // CONFIRM PASSWORD FIELD
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      style: const TextStyle(
                          color: Colors.white, fontFamily: "Helvetica"),
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: fieldColor,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF8B5CF6), width: 1.5),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () =>
                              setState(() => obscureConfirm = !obscureConfirm),
                          child: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // DONE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: "Helvetica",
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
