import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:link_up/core/services/firestore_service.dart';
import 'package:link_up/features/auth/core/data/models/user_model.dart';

import '../../../core/enums/alert_type.dart';
import '../../../core/widgets/alert_dialogs/app_alert_dialogs.dart';
import '../../../core/widgets/snack_bar/app_snack_bar.dart';
import '../../auth/core/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final _authController = Get.find<AuthController>();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Form controllers
  late final TextEditingController fullNameController;
  late final TextEditingController userNameController;
  late final TextEditingController phoneController;
  late final TextEditingController bioController;
  late final TextEditingController dobController;
  final Rx<String> _email = Rx<String>("");
  final Rx<String> _photoUrl = Rx<String>("");

  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<bool> _isEditing = Rx<bool>(false);
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  bool get isLoading => _isLoading.value;
  UserModel? get currentUser => _currentUser.value;
  bool get isEditing => _isEditing.value;
  String get photoUrl => _photoUrl.value;
  String get email => _email.value;

  @override
  void onInit() {
    super.onInit();
    _initFormControllers();
    _loadUserData();
  }

  // Initial form controllers
  void _initFormControllers() {
    final user = _authController.userData;
    fullNameController = TextEditingController(text: user?.fullName ?? '');
    userNameController = TextEditingController(text: user?.userName ?? '');
    phoneController = TextEditingController(text: user?.mobile ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
    dobController = TextEditingController(text: user?.dob ?? '');
    _email.value = user?.email ?? '';
    _photoUrl.value = user?.photoUrl ?? '';
  }

  // Load user data by stream
  void _loadUserData() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _currentUser.bindStream(
        _firestoreService.getUserStream(userId: currentUserId),
      );

      ever(_currentUser, (UserModel? user) {
        if (user != null) {
          fullNameController.text = user.fullName;
          userNameController.text = user.userName;
          phoneController.text = user.mobile;
          bioController.text = user.bio;
          dobController.text = user.dob;
          _email.value = user.email;
          _photoUrl.value = user.photoUrl;
        }
      });
    }
  }

  // Enable toggle editing
  void toggleEditing() {
    _isEditing.value = !_isEditing.value;

    if (!_isEditing.value) {
      final user = _currentUser.value;

      if (user != null) {
        // fullNameController.text = user.fullName;
        // emailController.text = user.email;
      }
    }
  }

  // Reset form data
  void _resetFormToCurrentData() {
    final user = _currentUser.value;

    if (user == null) return;
    fullNameController.text = user.fullName;
    userNameController.text = user.userName;
    phoneController.text = user.mobile;
    bioController.text = user.bio;
    dobController.text = user.dob;

    _photoUrl.value = user.photoUrl;
  }

  // Save profile changes
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      final user = _currentUser.value;
      if(user == null) return;

      final updatedUserData = user.copyWith(
        // fullName: fullNameController.text
      );
      await _firestoreService.updateUser(updatedUserData);

      _isEditing.value = false;

      AppSnackBar.success(
        title: 'Profile Updated',
        message: 'Your profile has been updated successfully.',
        context: Get.context!,
      );
    } catch (e) {
      Get.dialog(
        AppAlertDialog(
          title: 'Update Failed',
          message: e.toString().replaceAll('Exception: ', ''),
          type: AlertType.error,
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Sign out — delegates to AuthController
  Future<void> signOut() async {
    final confirmed = await Get.dialog<bool>(
      AppAlertDialog(
        title: 'Sign Out',
        message: 'Are you sure you want to sign out?',
        type: AlertType.warning,
      ),
    );
    if (confirmed == true) await _authController.signOut();
  }

  // Delete account — delegates to AuthController
  Future<void> deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AppAlertDialog(
        title: 'Delete Account',
        message: 'This action is permanent and cannot be undone.',
        type: AlertType.error,
      ),
    );
    if (confirmed == true) await _authController.deleteAccount();
  }
}
