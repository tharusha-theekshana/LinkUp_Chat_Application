import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_routes.dart';
import '../../../../../core/constants/app_regex.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../../../core/widgets/text_field/app_text_field.dart';
import '../../../core/widgets/step_indicator.dart';
import '../controllers/sign_up_controller.dart';
import '../../../core/controllers/auth_controller.dart';

class SignUpBasicDetailsView extends StatefulWidget {
  const SignUpBasicDetailsView({super.key});

  @override
  State<SignUpBasicDetailsView> createState() => _SignUpBasicDetailsViewState();
}

class _SignUpBasicDetailsViewState extends State<SignUpBasicDetailsView> {
  late Size _deviceSize;
  final int _currentStep = 0;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileNumberController = TextEditingController();

  // Controllers
  final _authController = Get.find<AuthController>();
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
          StepIndicator(totalSteps: 4, currentStep: _currentStep),
          SizedBox(height: _deviceSize.height * 0.015),
          _goToNextStepButton(),
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
            'Create Account',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Text(
            'Join LinkUp today to connect with friends, share experiences, and discover new communities.',
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
            controller: _nameController,
            label: 'Full Name',
            hintText: 'Jhon Anthony',
            prefixIcon: Icons.abc,
            keyboardType: TextInputType.text,
            maxLength: 30,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              if (!AppRegex.fullNameRegex.hasMatch(value)) {
                return 'Name can only contain letters';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          AppTextField(
            controller: _userNameController,
            label: 'User name',
            hintText: 'Jhon',
            prefixIcon: Icons.abc,
            keyboardType: TextInputType.text,
            maxLength: 15,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'User name is required';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'Jhon@example.com',
            prefixIcon: Icons.mail,
            keyboardType: TextInputType.emailAddress,
            maxLength: 75,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!AppRegex.emailRegex.hasMatch(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          AppTextField(
            controller: _mobileNumberController,
            label: 'Mobile Number',
            hintText: '07XXXXXXXX',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.number,
            maxLength: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mobile number is required';
              }
              if (!AppRegex.mobileNumberRegex.hasMatch(value)) {
                return 'Enter a valid mobile number';
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
      await _signUpController.setBasicData(
        fullName: _nameController.text,
        userName: _userNameController.text,
        email: _emailController.text,
        mobileNumber: _mobileNumberController.text,
      );

      Get.toNamed(AppRoutes.signUpSetPassword);
    } else {
      Get.log("Form is not valid");
    }
  }
}
