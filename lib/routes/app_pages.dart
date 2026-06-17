import 'package:get/get.dart';

import 'app_routes.dart';
import '../features/splash/views/splash_view.dart';
import '../features/auth/features/sign_in/views/sign_in_view.dart';
import '../features/auth/features/sign_up/views/sign_up_basic_details_view.dart';
import '../features/auth/features/sign_up/views/sign_up_set_password_view.dart';
import '../features/auth/features/sign_up/views/sign_up_bio_details_view.dart';
import '../features/auth/features/sign_up/views/sign_up_profile_pic_view.dart';
import '../features/auth/features/sign_up/bindings/sign_up_bindings.dart';

class AppPages {

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),

    // Auth
    GetPage(name: AppRoutes.login, page: () => SignInView()),

    GetPage(name: AppRoutes.signUpBasicDetails, page: () => SignUpBasicDetailsView(), binding: SignUpBindings()),
    GetPage(name: AppRoutes.signUpSetPassword, page: () => SignUpSetPasswordView(), binding: SignUpBindings()),
    GetPage(name: AppRoutes.signUpProfilePicDetails, page: () => SignUpProfilePicView(), binding: SignUpBindings()),
    GetPage(name: AppRoutes.signUpBioDetails, page: () => SignUpBioDetailsView(), binding: SignUpBindings()),
  ];

}