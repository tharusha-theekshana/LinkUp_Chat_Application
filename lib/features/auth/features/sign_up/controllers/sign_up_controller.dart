import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../routes/app_routes.dart';
import '../../../../../core/utils/app_error_handler.dart';
import '../../../../../core/utils/app_messages.dart';
import '../../../../../core/enums/alert_type.dart';
import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/widgets/alert_dialogs/app_alert_dialogs.dart';
import '../../../../../core/widgets/snack_bar/app_snack_bar.dart';
import '../../../core/data/entities/user_data_entity.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../../../core/services/firestore_service.dart';

class SignUpController extends GetxController {
  final _firestoreService = Get.find<FirestoreService>();
  final _authController = Get.find<AuthController>();

  final ImagePicker _picker = ImagePicker();
  XFile? image;

  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<String> _fullName = Rx<String>("");
  final Rx<String> _userName = Rx<String>("");
  final Rx<String> _email = Rx<String>("");
  final Rx<String> _mobile = Rx<String>("");
  final Rx<String> _password = Rx<String>("");
  final Rx<String> _bio = Rx<String>("");
  final Rx<String> _dateOfBirth = Rx<String>("");
  final Rx<File?> _profileImage = Rx<File?>(null);
  final Rx<bool> _isEmailVerified = Rx<bool>(false);

  final Rx<int> _resendCountdown = Rx<int>(60);
  final Rx<bool> _canResend = Rx<bool>(false);
  Timer? _countdownTimer;
  Timer? _verificationCheckTimer;

  // Getters
  bool get isLoading => _isLoading.value;
  String get fullName => _fullName.value;
  String get userName => _userName.value;
  String get email => _email.value;
  String get mobile => _mobile.value;
  String get password => _password.value;
  File? get profileImage => _profileImage.value;
  String get bio => _bio.value;
  String get dateOfBirth => _dateOfBirth.value;
  bool get isEmailVerified => _isEmailVerified.value;
  bool get canResend => _canResend.value;
  int get resendCountdown => _resendCountdown.value;

  // Store basic details in memory
  Future<void> setBasicData({
    required String fullName,
    required String userName,
    required String email,
    required String mobileNumber,
  }) async {
    _isLoading.value = true;
    try {
      final isExists = await _isEmailAlreadyInUse(email: email);

      if (isExists) {
        Get.dialog(
          AppAlertDialog(
            title: AppMessages.emailAlreadyInUse,
            message:
                "We found an existing account associated with this email address. Please log in to continue.",
            type: AlertType.error,
          ),
        );
        return;
      }

      _fullName.value = fullName;
      _userName.value = userName.toLowerCase();
      _email.value = email;
      _mobile.value = mobileNumber;

      // Navigate
      Get.toNamed(AppRoutes.signUpSetPassword);
    } catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Check email already exists in database
  Future<bool> _isEmailAlreadyInUse({required String email}) async {
    _isLoading.value = true;
    try {
      return await _firestoreService.isEmailAlreadyExists(email: email);
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Store password in memory
  Future<void> setPassword({required String password}) async {
    _isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));
      _password.value = password;

      // Navigate
      Get.toNamed(AppRoutes.signUpProfilePicDetails);
    } catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Select photo from album function
  Future<void> pickFromGallery() async {
    _isLoading.value = true;
    try {
      image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      _profileImage.value = File(image!.path);
    } catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Take photo from camera function
  Future<void> takePhoto() async {
    _isLoading.value = true;
    try {
      image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      _profileImage.value = File(image!.path);
    } catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Set profile image
  Future<void> setProfileImage() async {
    _isLoading.value = true;
    try {
      _profileImage.value = File(image!.path);
      Get.toNamed(AppRoutes.signUpBioDetails);
    } catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear image
  void clearProfileImage() {
    _profileImage.value = null;
  }

  // Store bio details in memory
  Future<void> setBioData({
    required String bio,
    required String dob,
    required selectedDate,
  }) async {
    _isLoading.value = true;
    try {
      if (!_isAgeValid(selectedDate)) {
        return Get.dialog(
          AppAlertDialog(
            title: AppMessages.ageRestriction,
            message:
                "You must be at least 13 years old to create a LinkUp account.",
            type: AlertType.restriction,
            buttonText: "Got It",
          ),
        );
      }

      _bio.value = bio;
      _dateOfBirth.value = dob;

      // Call register functionality
      await sendRegisterDataToAuth();
    } catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Store password in memory
  Future<void> sendRegisterDataToAuth() async {
    _isLoading.value = true;
    try {
      // Create model data
      UserDataEntity userDataEntity = UserDataEntity(
        fullName: fullName,
        userName: userName,
        email: email,
        password: password,
        mobile: mobile,
        profilePic: profileImage!,
        bio: bio,
        dob: dateOfBirth,
      );

      await _authController.registerWithEmailAndPassword(
        userData: userDataEntity,
      );
      Get.offNamed(AppRoutes.signUpEmailVerification);
    } on AppException catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    _isLoading.value = true;
    try {
      await _authController.resendVerificationEmail();
      startEmailVerifyListener();

      AppSnackBar.success(
        title: AppMessages.emailResent,
        message: "We've sent a new verification link to your email address.",
        context: Get.context!,
      );
    } catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Manual button check
  Future<void> checkEmailVerified() async {
    _isLoading.value = true;
    try {
      final verified = await _authController.checkEmailVerified();

      if (verified) {
        _verificationCheckTimer?.cancel();
        _countdownTimer?.cancel();
        await Future.delayed(const Duration(seconds: 3));
        Get.offAllNamed(AppRoutes.landing);
      } else {
        AppSnackBar.error(
          title: AppMessages.emailNotVerified,
          message:
              "Check your inbox and tap the verification link to continue.",
          context: Get.context!,
        );
      }
    } catch (e) {
      AppErrorHandler.showError(
        error: e,
        title: AppMessages.registrationFailed,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend timer start with listener
  void startEmailVerifyListener() {
    _resendCountdown.value = 60;
    _canResend.value = false;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown.value <= 1) {
        t.cancel();
        _canResend.value = true;
      } else {
        _resendCountdown.value--;
      }
    });

    // Listener every 3 seconds in the background
    _verificationCheckTimer?.cancel();
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      _,
    ) async {
      final verified = await _authController.checkEmailVerified();

      if (verified) {
        _verificationCheckTimer?.cancel();
        _countdownTimer?.cancel();

        _isLoading.value = true;

        AppSnackBar.success(
          title: AppMessages.emailVerified,
          message:
              "Your email has been verified successfully. Let's get you connected.",
          context: Get.context!,
        );

        // Update online status
        await _firestoreService.updateUserOnlineStatus(
          userId: _authController.user!.uid,
          isOnline: true,
        );

        await Future.delayed(const Duration(seconds: 2));

        _isLoading.value = false;
        Get.offAllNamed(AppRoutes.landing);
      }
    });
  }

  // Returns true if the user is 13 or older
  bool _isAgeValid(DateTime dob) {
    final DateTime today = DateTime.now();
    final DateTime thirteenYearsAgo = DateTime(
      today.year - 13,
      today.month,
      today.day,
    );
    return dob.isBefore(thirteenYearsAgo) ||
        dob.isAtSameMomentAs(thirteenYearsAgo);
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.onClose();
  }
}
