import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/features/auth/core/data/entities/user_data_entity.dart';

import '../../../../../core/enums/alert_type.dart';
import '../../../../../core/widgets/alert_dialogs/app_alert_dialogs.dart';
import '../../../../../core/widgets/snack_bar/app_snack_bar.dart';
import '../../../../../routes/app_routes.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../../../core/services/firestore_service.dart';
import '../../../core/services/auth_service.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final AuthService _authService = AuthService();

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
  int get resendCountdown =>
      _resendCountdown.value;

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

      if(isExists){
        Get.dialog(
          AppAlertDialog(
            title: "Email Already In Use",
            message: "We found an existing account associated with this email address. Please log in to continue.",
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
      throw Exception("Exception during set basic data ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  // Check email already exists in database
  Future<bool> _isEmailAlreadyInUse({required String email}) async {
    try {
      return await _firestoreService.isEmailAlreadyExists(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Store password in memory
  Future<void> setPassword({
    required String password
  }) async {
    _isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));
      _password.value = password;

      // Navigate
      Get.toNamed(AppRoutes.signUpProfilePicDetails);

    } catch (e) {
      throw Exception("Exception during set password ${e.toString()}");
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
      throw Exception("Exception during set profile image ${e.toString()}");
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
      throw Exception("Exception during set profile image ${e.toString()}");
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
      throw Exception("Exception during set profile image ${e.toString()}");
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
  }) async {
    _isLoading.value = true;
    try {
      _bio.value = bio;
      _dateOfBirth.value = dob;
    } catch (e) {
      throw Exception("Exception during set bio data ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  // Store password in memory
  Future<void> sendRegisterDataToAuth({
    required UserDataEntity userData
  }) async {
    _isLoading.value = true;
    try {
      await _authController.registerWithEmailAndPassword(userData: userData);

    } catch (e) {
      throw Exception("Exception during set password ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _authService.resendVerificationEmail();
      startResendTimer();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Manual button check
  Future<bool> checkEmailVerified() async {
    _isLoading.value = true;
    try {
      final verified = await _authService.checkEmailVerified();
      if (verified) {
        _verificationCheckTimer?.cancel();
        _countdownTimer?.cancel();
        await Future.delayed(const Duration(seconds: 3));
        Get.offAllNamed(AppRoutes.landing);
      } else {
        _isLoading.value = false;
      }
      return verified;
    } catch (e) {
      _isLoading.value = false;
      return false;
    }
  }

  // Resend timer start with listener
  void startResendTimer() {
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
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final verified = await _authService.checkEmailVerified();

      if (verified) {
        _verificationCheckTimer?.cancel();
        _countdownTimer?.cancel();

        _isLoading.value = true;

        AppSnackBar.success(
          title: "Email Verified",
          message: "Your email has been verified successfully. Let's get you connected.",
          context: Get.context!,
        );

        await Future.delayed(const Duration(seconds: 2));

        _isLoading.value = false;
        Get.offAllNamed(AppRoutes.landing);
      }
    });
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _verificationCheckTimer?.cancel();
    super.onClose();
  }
}