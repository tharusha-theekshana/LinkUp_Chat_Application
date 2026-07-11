import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_theme.dart';

class AppSnackBar {
  static void success({
    required String title,
    required String message,
    required BuildContext context,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: 13,
            color: AppTheme.successColor,
          ),
        ),
        messageText: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.cardColor,
        borderRadius: 15,
        margin: const EdgeInsets.all(14),
        snackPosition: SnackPosition.TOP,
        borderColor: AppTheme.successColor.withAlpha(150),
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: AppTheme.successColor),
      ),
    );
  }

  static void error({
    required String title,
    required String message,
    required BuildContext context,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: 13,
            color: AppTheme.errorColor,
          ),
        ),
        messageText: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.cardColor,
        borderRadius: 15,
        borderColor: AppTheme.errorColor.withAlpha(150),
        margin: const EdgeInsets.all(14),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: AppTheme.errorColor),
      ),
    );
  }

  static void warning({
    required String title,
    required String message,
    required BuildContext context,
  }) {

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: 13,
            color: AppTheme.warningColor,
          ),
        ),
        messageText: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.cardColor,
        borderRadius: 15,
        borderColor: AppTheme.warningColor.withAlpha(150),
        margin: const EdgeInsets.all(14),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: AppTheme.warningColor),
      ),
    );
  }
}
