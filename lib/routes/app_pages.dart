import 'package:get/get.dart';
import 'package:link_up/features/splash/views/splash_view.dart';
import 'package:link_up/routes/app_routes.dart';

class AppPages {

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
  ];

}