import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SignUpController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<String> _fullName = Rx<String>("");
  final Rx<String> _userName = Rx<String>("");
  final Rx<String> _email = Rx<String>("");
  final Rx<String> _mobile = Rx<String>("");
  final Rx<String> _password = Rx<String>("");
  final Rx<String> _bio = Rx<String>("");
  final Rx<String> _dateOfBirth = Rx<String>("");
  final Rx<File?> _profileImage = Rx<File?>(null);

  bool get isLoading => _isLoading.value;
  String get fullName => _fullName.value;
  String get userName => _userName.value;
  String get email => _email.value;
  String get mobile => _mobile.value;
  String get password => _password.value;
  File? get profileImage => _profileImage.value;
  String get bio => _bio.value;
  String get dateOfBirth => _dateOfBirth.value;

  // Store basic details in memory
  Future<void> setBasicData({
    required String fullName,
    required String userName,
    required String email,
    required String mobileNumber,
  }) async {
    _isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));

      _fullName.value = fullName;
      _userName.value = userName;
      _email.value = email;
      _mobile.value = mobileNumber;
    } catch (e) {
      throw Exception("Exception during set basic data ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  // Store basic details in memory
  Future<void> setPassword({
    required String password
  }) async {
    _isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));
      _password.value = password;
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
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setProfileImage(File(image.path));
      }
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
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setProfileImage(File(image.path));
      }
    } catch (e) {
      throw Exception("Exception during set profile image ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  // Set profile image
  Future<void> setProfileImage(File image) async {
    _isLoading.value = true;
    try {
      _profileImage.value = image;
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
}