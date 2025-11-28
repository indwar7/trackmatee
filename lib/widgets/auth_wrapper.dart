import 'package:flutter/material.dart';
import 'package:trackmate_app/screens/auth/login_screen.dart';
import 'package:trackmate_app/screens/home_screen.dart';
import 'package:trackmate_app/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No GetX instance required now — using static AuthService state
    return ValueListenableBuilder(
      valueListenable: AuthService.loginState, // listens for login changes
      builder: (context, value, _) {
        return AuthService.isLoggedIn
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}
