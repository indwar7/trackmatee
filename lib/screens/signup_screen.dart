import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPasswordFocused = false;
  
  String? _phoneError;
  bool _showPhoneInfo = false;
  bool _showEmailInfo = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+91';
    _phoneController.addListener(_validatePhone);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone == '+91') {
      setState(() {
        _phoneError = null;
        _showPhoneInfo = false;
      });
      return;
    }
    
    // Check if phone number is valid (10 digits after +91)
    // Remove +91 and check if remaining is 10 digits
    String phoneWithoutPrefix = phone;
    if (phone.startsWith('+91')) {
      phoneWithoutPrefix = phone.substring(3).trim();
    } else if (phone.startsWith('91')) {
      phoneWithoutPrefix = phone.substring(2).trim();
    }
    
    // Check if it's exactly 10 digits
    final phoneDigits = phoneWithoutPrefix.replaceAll(RegExp(r'[^\d]'), '');
    if (phoneDigits.length != 10) {
      setState(() {
        _phoneError = 'Please enter a valid phone number.';
        _showPhoneInfo = false;
      });
    } else {
      setState(() {
        _phoneError = null;
        _showPhoneInfo = true;
      });
    }
    _validateForm();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _showEmailInfo = false;
      });
      return;
    }
    
    final isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    setState(() {
      _showEmailInfo = isValid;
    });
    _validateForm();
  }

  bool _isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Map<String, bool> _getPasswordRequirements(String password) {
    return {
      'At least 8 characters': password.length >= 8,
      '1 Uppercase letter': password.contains(RegExp(r'[A-Z]')),
      '1 Lowercase letter': password.contains(RegExp(r'[a-z]')),
      '1 Special character': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      '1 Digit': password.contains(RegExp(r'[0-9]')),
    };
  }

  void _validateForm() {
    setState(() {});
  }

  bool _isFormValid() {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    // Phone validation
    if (phone.isEmpty || phone == '+91' || _phoneError != null || !_showPhoneInfo) {
      return false;
    }
    
    // Email validation
    if (email.isEmpty || !_showEmailInfo) return false;
    
    // Password validation
    if (!_isValidPassword(password)) return false;
    
    // Confirm password validation
    if (password != confirmPassword || confirmPassword.isEmpty) return false;
    
    return true;
  }

  void _onSignUp() {
    if (_isFormValid()) {
      // Handle sign up
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;
    final passwordRequirements = _getPasswordRequirements(password);
    final isFormValid = _isFormValid();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Sign up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Phone Number Input
              const Text(
                'Phone Number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '+91',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF16213E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              
              // Phone Error Message
              if (_phoneError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _phoneError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
              
              // Phone Info Message
              if (_showPhoneInfo && _phoneError == null) ...[
                const SizedBox(height: 8),
                Text(
                  "You'll need to verify that you own this phone number.",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Email Input
              const Text(
                'Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF16213E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              
              // Email Info Message
              if (_showEmailInfo) ...[
                const SizedBox(height: 8),
                Text(
                  "You'll need to verify that you own this email.",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Password Input
              const Text(
                'Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isPasswordFocused = hasFocus;
                  });
                },
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Confirm your Password',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF16213E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[400],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              
              // Password Requirements Box
              if (_isPasswordFocused) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: passwordRequirements.entries.map((requirement) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              requirement.value
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: requirement.value
                                  ? Colors.green
                                  : Colors.grey[400],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              requirement.key,
                              style: TextStyle(
                                color: requirement.value
                                    ? Colors.white
                                    : Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Confirm Password Input
              const Text(
                'Confirm Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Confirm your Password',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF16213E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isFormValid ? _onSignUp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormValid
                        ? const Color(0xFF8B5CF6) // Purple when valid
                        : Colors.grey[700], // Grey when invalid
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[700],
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Login Link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: 'Already a member? '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6), // Purple
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
