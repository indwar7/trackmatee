import 'package:get/get.dart';

class VerificationController extends GetxController {
  var isVerified = false.obs;

  void markVerified() => isVerified.value = true;
}
