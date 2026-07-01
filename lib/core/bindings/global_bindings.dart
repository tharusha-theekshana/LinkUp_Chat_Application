import 'package:get/get.dart';
import 'package:link_up/features/find_friends/controllers/find_friends_controller.dart';

import '../../features/auth/core/controllers/auth_controller.dart';
import '../../features/profile/controllers/profile_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.lazyPut<FindFriendsController>(() => FindFriendsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}