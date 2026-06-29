import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/widgets/scaffold/app_scaffold.dart';

import '../../../../../routes/app_routes.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../core/constants/app_regex.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/logo/app_logo.dart';
import '../../../../../core/widgets/text_field/app_text_field.dart';
import '../../../core/widgets/divider_text.dart';
import '../../../../../core/widgets/texts/app_copyright_footer.dart';
import '../../../core/controllers/auth_controller.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  late Size _deviceSize;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controllers
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      deviceSize: _deviceSize,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _topWidgets(),
            Expanded(child: _bodyWidgets()),
            _footerWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _topWidgets() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        vertical: _deviceSize.height * 0.015,
      ),
      child: AppLogo(size: _deviceSize.height * 0.2),
    );
  }

  Widget _bodyWidgets() {
    return Column(
      children: [
        SizedBox(height: _deviceSize.height * 0.02),
        _viewTexts(),
        SizedBox(height: _deviceSize.height * 0.025),
        _formArea(),
        SizedBox(height: _deviceSize.height * 0.045),
        _linkArea(),
      ],
    );
  }

  Widget _footerWidgets() {
    return AppCopyrightFooter();
  }

  // Text areas
  Widget _viewTexts() {
    return SizedBox(
      width: _deviceSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Text(
            'Sign in to continue your conversations and stay connected with friends and communities.',
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
          SizedBox(height: 10),
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
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
          SizedBox(height: 20),
          _signInButton(),
        ],
      ),
    );
  }

  Widget _linkArea() {
    return Column(
      children: [
        _forgotPassword(),
        SizedBox(height: _deviceSize.height * 0.025),
        DividerText(),
        SizedBox(height: _deviceSize.height * 0.025),
        _signUpLink(),
      ],
    );
  }

  // Forgot password text area
  Widget _forgotPassword() {
    return GestureDetector(
      onTap: ()  => Get.toNamed(AppRoutes.forgotPassword),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Forgot Password ?",
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  // Sign up link
  Widget _signUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account ? ",
          style: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.signUpBasicDetails),
          child: Text(
            ' Sign up',
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // Sign in button
  Widget _signInButton() {
    return Obx(
      () => AppButton(
        label: 'Sign in',
        isLoading: _authController.isLoading,
        onPressed: () => _signIn(),
      ),
    );
  }

  // Sign in function
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      await _authController.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      Get.log("Form is not valid");
    }
  }
}
