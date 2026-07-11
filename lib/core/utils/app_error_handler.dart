import 'package:get/get.dart';

import '../enums/alert_type.dart';
import '../exceptions/app_exception.dart';
import '../widgets/alert_dialogs/app_alert_dialogs.dart';

class AppErrorHandler {
  static void showError({required dynamic error, String title = "Something went wrong"}) {
    final message = error is AppException
        ? error.message
        : 'We ran into an issue processing your request. Please try again.';

    Get.dialog(
      AppAlertDialog(
        title: title,
        message: message,
        type: AlertType.error,
      ),
    );
  }
}