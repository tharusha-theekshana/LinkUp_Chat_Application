import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../theme/app_theme.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../../../core/widgets/snack_bar/app_snack_bar.dart';
import '../controllers/sign_up_controller.dart';

class SignUpEmailVerification extends StatefulWidget {
  const SignUpEmailVerification({super.key});

  @override
  State<SignUpEmailVerification> createState() =>
      _SignUpEmailVerificationState();
}

class _SignUpEmailVerificationState extends State<SignUpEmailVerification> {
  late Size _deviceSize;
  final _signUpController = Get.find<SignUpController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _signUpController.startResendTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: AppScaffold(
        deviceSize: _deviceSize,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: _deviceSize.height * 0.12),
            _topIcon(),
            SizedBox(height: _deviceSize.height * 0.04),
            _viewTexts(),
            SizedBox(height: _deviceSize.height * 0.03),
            _stepCard(),
            Expanded(child: SizedBox()),
            _resendEmailButton(),
            SizedBox(height: _deviceSize.height * 0.025),
            _verifiedEmailButton(),
          ],
        ),
      ),
    );
  }

  // Top icon
  Widget _topIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(50),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor.withAlpha(150),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.mark_email_unread_rounded,
        size: 44,
        color: AppTheme.primaryColor,
      ),
    );
  }

  // Text areas
  Widget _viewTexts() {
    return SizedBox(
      width: _deviceSize.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Check Your Email',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Obx(
            () => RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(text: 'We sent a verification link to\n'),
                  TextSpan(
                    text: _signUpController.email,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text:
                        '\n\nOpen the email and tap the link to verify your account.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Steps card
  Widget _stepCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _stepRow(number: '1', text: 'Open your email inbox'),
          const SizedBox(height: 16),
          _stepRow(number: '2', text: 'Locate the verification email from LinkUp'),
          const SizedBox(height: 16),
          _stepRow(number: '3', text: 'Tap the "Verify Email" button in the email'),
          const SizedBox(height: 16),
          _stepRow(
            number: '4',
            text: 'Once your email is verified, app will update automatically.',
          ),
        ],
      ),
    );
  }

  Widget _verifiedEmailButton() {
    return Obx(
      () => AppButton(
        label: "I've verified my email",
        isLoading: _signUpController.isLoading,
        onPressed: () async {
          final verified = await _signUpController.checkEmailVerified();

          if (!verified) {
            AppSnackBar.error(
              title: "Not verified yet",
              message: "Please click the link in your email first.",
              context: Get.context!,
            );
          }
        },
      ),
    );
  }

  // Resend email button
  Widget _resendEmailButton() {
    return Obx(() {
      final canResend = _signUpController.canResend;
      final countdown = _signUpController.resendCountdown;

      return GestureDetector(
        onTap: canResend
            ? () async {
          await _signUpController.resendVerificationEmail();
          AppSnackBar.success(
            title: "Email resent",
            message: "Check your inbox for a new link.",
            context: Get.context!,
          );
        }
            : null,
        child: Text(
          canResend ? 'Resend email' : 'Resend in ${countdown}s',
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      );
    });
  }

  Widget _stepRow({required String number, required String text}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.textSecondaryColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.cardColor,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.cardColor,
            ),
          ),
        ),
      ],
    );
  }
}
