import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/features/auth/features/forgot_password/widgets/email_sent_bottom_sheet.dart';

import '../../../../../core/constants/app_regex.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../../../core/widgets/text_field/app_text_field.dart';
import '../../../core/controllers/auth_controller.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late Size _deviceSize;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _emailController = TextEditingController();

  // Controllers
  final _authController = Get.find<AuthController>();
  final _forgotPasswordController = Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      appBar: AppBar(),
      deviceSize: _deviceSize,
      body: Column(
        children: [
          _viewTexts(),
          SizedBox(height: _deviceSize.height * 0.025),
          _formArea(),
          SizedBox(height: _deviceSize.height * 0.025),
          _sendLinkButton(),
        ],
      ),
    );
  }

  // Text areas
  Widget _viewTexts() {
    return SizedBox(
      width: _deviceSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forgot Password',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Text(
            'Enter your registered email address. We will send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Form area
  Widget _formArea() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            maxLength: 100,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!AppRegex.emailRegex.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Send link button
  Widget _sendLinkButton() {
    return Obx(
      () => AppButton(
        label: 'Send Reset Link',
        isLoading: _forgotPasswordController.isLoading,
        onPressed: () => _sendResetLink(),
      ),
    );
  }

  // Send reset link button function
  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      await _forgotPasswordController.setResetEmail(
        email: _emailController.text,
      );
      await _authController.sendPasswordResetEmail(
        email: _emailController.text,
      );

      Get.bottomSheet(
        EmailSentBottomSheet(deviceSize: _deviceSize,),
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
      );
    } else {
      Get.log("Form is not valid");
    }
  }
}
