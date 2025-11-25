import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final _isLoggedIn = false.obs;
  final _token = ''.obs;
  final _box = GetStorage();

  bool get isLoggedIn => _isLoggedIn.value;
  String get token => _token.value;

  @override
  void onInit() {
    super.onInit();
    // Load auth state when service initializes
    _isLoggedIn.value = _box.read('isLoggedIn') ?? false;
    _token.value = _box.read('token') ?? '';
  }

  Future<void> login(String email, String password) async {
    try {
      // Here you would typically make an API call to your backend
      // For now, we'll simulate a successful login
      await Future.delayed(const Duration(seconds: 1));
      
      // Save auth state
      _isLoggedIn.value = true;
      _token.value = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
      
      await _box.write('isLoggedIn', true);
      await _box.write('token', _token.value);
      await _box.write('email', email);
      
      return; // Success
    } catch (e) {
      throw 'Login failed. Please try again.';
    }
  }

  Future<void> logout() async {
    try {
      // Here you would typically make an API call to invalidate the token
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear auth state
      _isLoggedIn.value = false;
      _token.value = '';
      
      await _box.remove('isLoggedIn');
      await _box.remove('token');
      await _box.remove('email');
      
      return; // Success
    } catch (e) {
      throw 'Logout failed. Please try again.';
    }
  }

  // Add this method to check if user is logged in
  bool isAuthenticated() {
    return _isLoggedIn.value && _token.value.isNotEmpty;
  }
}

// Initialize the auth service
Future<AuthService> initAuthService() async {
  final authService = Get.put(AuthService());
  await Get.putAsync(() => Future.value(authService), permanent: true);
  return authService;
}
