import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trackmate_app/screens/auth/login_screen.dart';
import 'package:trackmate_app/screens/home_screen.dart';
import 'package:trackmate_app/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    
    return Obx(() {
      return authService.isLoggedIn ? const HomeScreen() : const LoginScreen();
    });
  }
}
