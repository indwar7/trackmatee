import 'package:get/get.dart';

class IdCaptureController extends GetxController {
  var isFrontCaptured = false.obs;
  var isBackCaptured = false.obs;

  void setFront(bool v) => isFrontCaptured.value = v;
  void setBack(bool v) => isBackCaptured.value = v;
}
