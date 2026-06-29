import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_regex.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../../../core/widgets/text_field/app_text_field.dart';
import '../../../core/widgets/step_indicator.dart';
import '../controllers/sign_up_controller.dart';

class SignUpSetPasswordView extends StatefulWidget {
  const SignUpSetPasswordView({super.key});

  @override
  State<SignUpSetPasswordView> createState() => _SignUpSetPasswordViewState();
}

class _SignUpSetPasswordViewState extends State<SignUpSetPasswordView> {
  late Size _deviceSize;
  final int _currentStep = 1;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers
  final _signUpController = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      deviceSize: _deviceSize,
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _viewTexts(),
          SizedBox(height: _deviceSize.height * 0.025),
          Expanded(child: _formArea()),
          StepIndicator(
            totalSteps: 4,
            currentStep: _currentStep,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          _goToNextStepButton(),
        ],
      ),);
  }

  // Text areas
  Widget _viewTexts() {
    return SizedBox(
      width: _deviceSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Password',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Text(
            'Choose a strong password to keep your account secure and protect your personal information.',
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
            controller: _passwordController,
            label: 'Password',
            hintText: '********',
            prefixIcon: Icons.password,
            keyboardType: TextInputType.text,
            isPassword: true,
            maxLength: 20,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              } else if (!AppRegex.passwordRegex.hasMatch(value)) {
                return 'Password must have at least one uppercase letter and one number';
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          AppTextField(
            controller: _confirmPasswordController,
            label: 'Confirm password',
            hintText: '********',
            prefixIcon: Icons.password,
            keyboardType: TextInputType.text,
            maxLength: 20,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password confirmation is required';
              } else  if(value != _passwordController.text){
                return 'Password is not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Next step button
  Widget _goToNextStepButton() {
    return Obx(
          () => AppButton(
        label: 'Next Step',
        isLoading: _signUpController.isLoading,
        onPressed: () => _goToNextStep(),
      ),
    );
  }

  // Next step button function
  Future<void> _goToNextStep() async {
    if (_formKey.currentState!.validate()) {
      await _signUpController.setPassword(password: _passwordController.text);

    } else {
      Get.log("Form is not valid");
    }
  }

}
