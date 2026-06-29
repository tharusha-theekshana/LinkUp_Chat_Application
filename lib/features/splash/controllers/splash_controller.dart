import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../auth/core/controllers/auth_controller.dart';

class SplashController extends GetxController {
  final _authController = Get.find<AuthController>();

  void checkAuthAndNavigate() async {
    await Future.delayed(Duration(seconds: 3));
    final user = _authController.user;

    try{
      await user?.reload();

      // If user data null
      if(user == null){
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // If user exists without email verification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        Get.offAllNamed(AppRoutes.signUpEmailVerification);
        return;
      }
    }catch(e){
      Get.offAllNamed(AppRoutes.login);
    }
    Get.offAllNamed(AppRoutes.landing);
  }
}
