import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/widgets/snack_bar/app_snack_bar.dart';
import 'package:link_up/routes/app_routes.dart';
import 'package:link_up/theme/app_theme.dart';

import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../core/controllers/auth_controller.dart';
import '../controllers/forgot_password_controller.dart';

class EmailSentBottomSheet extends StatelessWidget {
  final Size deviceSize;

  EmailSentBottomSheet({required this.deviceSize, super.key});

  final _authController = Get.find<AuthController>();
  final _forgotPasswordController = Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.textSecondaryColor.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: deviceSize.height * 0.04),
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.green.shade50,
            child: Icon(
              Icons.mark_email_read_outlined,
              color: AppTheme.successColor,
              size: 34,
            ),
          ),
          SizedBox(height: deviceSize.height * 0.04),
          Text(
            'Check your email',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: deviceSize.height * 0.02),
          Obx(
            () => Text.rich(
              TextSpan(
                text: 'A password reset link has been sent to\n',
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: _forgotPasswordController.email,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        '.\n\nPlease check your inbox and follow the instructions to reset your password.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: deviceSize.height * 0.04),
          AppButton(
            label: 'Back to Login',
            height: deviceSize.height * 0.06,
            labelStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.cardColor,
            ),
            onPressed: () => Get.offAllNamed(AppRoutes.login),
          ),
          SizedBox(height: deviceSize.height * 0.025),
          GestureDetector(
            onTap: () => _resendEmail(),
            child: Text(
              "Didn't receive it? Resend",
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Resend email
  Future<void> _resendEmail() async {
    _authController.sendPasswordResetEmail(
      email: _forgotPasswordController.email,
    );
    AppSnackBar.success(
      title: "Email Sent",
      message: "A password reset link has been sent to your email address.",
      context: Get.context!,
    );
  }
}
