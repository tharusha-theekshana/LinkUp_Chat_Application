import 'package:get/get.dart';

import '../../features/auth/core/controllers/auth_controller.dart';
import '../../features/find_friends/controllers/find_friends_controller.dart';
import '../../features/friends/controllers/friends_controller.dart';
import '../../features/profile/controllers/profile_controller.dart';
import '../services/firestore_service.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirestoreService>(() => FirestoreService(),fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(),fenix: true);
    Get.lazyPut<FriendsController>(() => FriendsController());
    Get.lazyPut<FindFriendsController>(() => FindFriendsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}