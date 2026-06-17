import 'package:get/get.dart';

import '../../features/auth/core/controllers/auth_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}