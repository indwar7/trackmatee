import 'package:flutter/material.dart';

class PasswordChecklist extends StatelessWidget {
  final bool hasMinLen;
  final bool hasUpper;
  final bool hasLower;
  final bool hasNumber;
  final bool hasSpecial;

  const PasswordChecklist({
    super.key,
    required this.hasMinLen,
    required this.hasUpper,
    required this.hasLower,
    required this.hasNumber,
    required this.hasSpecial,
  });

  Widget _row(bool valid, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: valid ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF141418),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(hasMinLen, "At least 8 characters"),
            _row(hasUpper, "Contains uppercase"),
            _row(hasLower, "Contains lowercase"),
            _row(hasNumber, "Contains number"),
            _row(hasSpecial, "Contains special character"),
          ],
        ),
      ),
    );
  }
}
