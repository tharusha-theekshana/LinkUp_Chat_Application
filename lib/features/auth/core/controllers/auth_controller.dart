import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../data/entities/user_data_entity.dart';
import '../data/models/user_model.dart';
import '../../../../core/enums/alert_type.dart';
import '../../../../core/widgets/alert_dialogs/app_alert_dialogs.dart';
import '../../../../core/widgets/snack_bar/app_snack_bar.dart';
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
    _isLoading.value = true;
    try {
      UserModel? user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _userData.value = user;
        Get.offAllNamed(AppRoutes.landing);
      }

    } catch (e) {
      return Get.dialog(
        AppAlertDialog(
          title: "Login Failed",
          message: e.toString().replaceAll('Exception: ', ''),
          type: AlertType.error,
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Register with email and password
  Future<void> registerWithEmailAndPassword({
    required UserDataEntity userData,
  }) async {
    _isLoading.value = true;
    try {
      UserModel? user = await _authService.registerWithEmailAndPassword(
        userData: userData,
      );

      if (user != null) {
        AppSnackBar.success(
          title: "Registration Success",
          message: "You're all set! Your account is ready to use.",
          context: Get.context!
        );

        _userData.value = user;
        Get.offAllNamed(AppRoutes.login);
      }

    } catch (e) {
      return Get.dialog(
        AppAlertDialog(
          title: "Registration Failed",
          message: e.toString().replaceAll('Exception: ', ''),
          type: AlertType.error,
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Forgot password send password rest email
  Future<void> sendPasswordResetEmail({required String email}) async {
    _isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: email);

    } catch (e) {
      throw Exception(
        "Exception during send password rest email ${e.toString()}",
      );
    } finally {
      _isLoading.value = false;
    }
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
