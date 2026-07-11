import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../data/entities/user_data_entity.dart';
import '../data/models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userData = Rx<UserModel?>(null);
  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<String> _error = Rx<String>("");

  bool get isAuthenticated => _user.value != null;
  final Rx<bool> _isInitialized = Rx<bool>(false);

  User? get user => _user.value;

  UserModel? get userData => _userData.value;

  bool get isLoading => _isLoading.value;

  String get error => _error.value;

  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();

    _user.bindStream(_authService.authStateChanges);
    ever(_user, _handleAuthStateChange);
  }

  void _handleAuthStateChange(User? user) {
    if (_isInitialized.value == false) {
      _isInitialized.value = true;
    }
  }

  void checkInitialAuthState() {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      _user.value = currentUser;
      Get.offAllNamed(AppRoutes.landing);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }

    _isInitialized.value = true;
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    UserModel? user = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (user != null) {
      _userData.value = user;
      Get.offAllNamed(AppRoutes.landing);
    }
  }

  // Register with email and password
  Future<void> registerWithEmailAndPassword({
    required UserDataEntity userData,
  }) async {
    UserModel? user = await _authService.registerWithEmailAndPassword(
      userData: userData,
    );

    if (user != null) {
      _userData.value = user;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  // Check if email is verified (reload user first)
  Future<bool> checkEmailVerified() async {
    return await _authService.checkEmailVerified();
  }

  // Forgot password send password rest email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out with firebase
  Future<void> signOut() async {
    _isLoading.value = true;
    try {
      await _authService.signOut();
      _userData.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      throw Exception("Exception during sign out ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    _isLoading.value = true;
    try {
      await _authService.deleteAccount();
      _userData.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      throw Exception("Exception during delete account ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }
}
