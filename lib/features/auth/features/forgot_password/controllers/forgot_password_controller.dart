import 'dart:math';

import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<String> _email = Rx<String>("");

  bool get isLoading => _isLoading.value;
  String get email => _email.value;

  // Store email details in memory
  Future<void> setResetEmail({required String email}) async {
    _isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));
      _email.value = email;
    } catch (e) {
      throw Exception("Exception during set email ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }
}
