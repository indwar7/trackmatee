import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary Colors
  static const Color primary = Color(0xFF7C3AED);     // Purple
  static const Color primaryDark = Color(0xFF5A26C8);
  static const Color primaryLight = Color(0xFF9A6CFF);

  // Backgrounds
  static const Color bgDark = Color(0xFF1A1A1A);
  static const Color bgCard = Color(0xFF2A2A3E);
  static const Color bgLight = Color(0xFF2F2F45);

  // Text Colors
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF9DA3AF);
  static const Color textFade = Colors.white60;

  // Success / Alerts
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);

  // Border / Divider
  static const Color borderGrey = Color(0xFF3C3C50);

  // Buttons
  static const Color btnPrimary = primary;
  static const Color btnSecondary = Color(0xFF41415A);

  // Transparent overlays
  static const Color overlayDark = Colors.black54;
  static const Color overlayLight = Colors.white54;
  static Color get secondaryColor => const Color(0xFF7C3AED); // purple shade

}
