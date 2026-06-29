import 'package:get/get.dart';

import 'app_routes.dart';
import '../features/splash/views/splash_view.dart';
import '../features/splash/bindings/splash_bindings.dart';
import '../features/landing/views/landing_view.dart';
import '../features/auth/features/sign_in/views/sign_in_view.dart';
import '../features/auth/features/sign_up/bindings/sign_up_bindings.dart';
import '../features/auth/features/sign_up/views/sign_up_basic_details_view.dart';
import '../features/auth/features/sign_up/views/sign_up_set_password_view.dart';
import '../features/auth/features/sign_up/views/sign_up_email_verification.dart';
import '../features/auth/features/sign_up/views/sign_up_bio_details_view.dart';
import '../features/auth/features/sign_up/views/sign_up_profile_pic_view.dart';
import '../features/auth/features/forgot_password/views/forgot_password_view.dart';
import '../features/auth/features/forgot_password/bindings/forgot_password_bindings.dart';
import '../features/profile/views/profile_view.dart';
import '../features/profile/bindings/profile_bindings.dart';

class AppPages {

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView(),binding: SplashBinding()),

    // Landing
    GetPage(name: AppRoutes.landing, page: () => const LandingView()),

    // Auth - login
    GetPage(name: AppRoutes.login, page: () => SignInView()),

    // Auth - register
    GetPage(name: AppRoutes.signUpBasicDetails, page: () => SignUpBasicDetailsView(), binding: SignUpBindings()),
    GetPage(name: AppRoutes.signUpSetPassword, page: () => SignUpSetPasswordView(), binding: SignUpBindings()),
    GetPage(name: AppRoutes.signUpEmailVerification, page: () => SignUpEmailVerification(), binding: SignUpBindings()),
    GetPage(name: AppRoutes.signUpProfilePicDetails, page: () => SignUpProfilePicView(), binding: SignUpBindings()),
    GetPage(name: AppRoutes.signUpBioDetails, page: () => SignUpBioDetailsView(), binding: SignUpBindings()),

    // Auth - forgot password
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordView(), binding: ForgotPasswordBindings()),

    // Profile
    GetPage(name: AppRoutes.profile, page: () => ProfileView(), binding: ProfileBindings()),
  ];

}