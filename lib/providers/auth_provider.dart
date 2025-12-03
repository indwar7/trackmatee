// lib/services/auth_service.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxController {
  final _storage = GetStorage();

  var isAuthenticated = false.obs;
  var userId = ''.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var phoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final storedUserId = _storage.read('userId');
    if (storedUserId != null) {
      userId.value = storedUserId;
      userName.value = _storage.read('userName') ?? '';
      userEmail.value = _storage.read('userEmail') ?? '';
      phoneNumber.value = _storage.read('phoneNumber') ?? '';
      isAuthenticated.value = true;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Call your API
      // For now, just mock login
      userId.value = 'user_123';
      userName.value = 'Tanvee Saxena';
      userEmail.value = email;
      isAuthenticated.value = true;

      // Save to storage
      await _storage.write('userId', userId.value);
      await _storage.write('userName', userName.value);
      await _storage.write('userEmail', userEmail.value);

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    }
  }

  Future<void> logout() async {
    userId.value = '';
    userName.value = '';
    userEmail.value = '';
    phoneNumber.value = '';
    isAuthenticated.value = false;

    await _storage.erase();
    Get.offAllNamed('/login');
  }
}