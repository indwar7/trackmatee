import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final _isLoggedIn = false.obs;
  final _token = ''.obs;
  final _email = ''.obs;
  final _username = ''.obs;

  final _box = GetStorage();

  // ValueNotifier for ValueListenableBuilder
  static final ValueNotifier<bool> loginState = ValueNotifier<bool>(false);

  // GETTERS
  bool get isLoggedIn => _isLoggedIn.value;
  String get token => _token.value;
  String get email => _email.value;
  String get username => _username.value;

  @override
  void onInit() {
    super.onInit();

    _isLoggedIn.value = _box.read('isLoggedIn') ?? false;
    _token.value = _box.read('token') ?? '';
    _email.value = _box.read('email') ?? '';
    _username.value = _box.read('username') ?? 'User';

    // Update the static loginState
    loginState.value = _isLoggedIn.value;

    // Listen to changes in _isLoggedIn and sync with loginState
    ever(_isLoggedIn, (value) {
      loginState.value = value;
    });
  }

  // CALL THIS AFTER LOGIN API SUCCESS
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    _isLoggedIn.value = true;
    _token.value = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
    _email.value = email;
    _username.value = email.split('@')[0]; // TEMP – until API sends real name

    await _box.write('isLoggedIn', true);
    await _box.write('token', _token.value);
    await _box.write('email', _email.value);
    await _box.write('username', _username.value);

    // loginState.value will be updated automatically via the ever() listener
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));

    _isLoggedIn.value = false;
    _token.value = '';
    _email.value = '';
    _username.value = '';

    await _box.erase(); // complete wipe – safest

    Get.offAllNamed('/login');
  }
}

Future<AuthService> initAuthService() async {
  Get.put(AuthService());
  return Get.find<AuthService>();
}