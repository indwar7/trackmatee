class Validators {
  static bool hasMinLen(String p) => p.length >= 8;
  static bool hasUpper(String p) => p.contains(RegExp(r'[A-Z]'));
  static bool hasLower(String p) => p.contains(RegExp(r'[a-z]'));
  static bool hasNumber(String p) => p.contains(RegExp(r'[0-9]'));

  // 100% VALID, SAFE, NO ESCAPES NEEDED
  static bool hasSpecial(String p) =>
      p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\/\[\];`~+=]'));
}
