import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../theme/app_theme.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../../../core/widgets/snack_bar/app_snack_bar.dart';
import '../widgets/upload_option_tile.dart';
import '../../../core/widgets/step_indicator.dart';
import '../controllers/sign_up_controller.dart';

class SignUpProfilePicView extends StatefulWidget {
  const SignUpProfilePicView({super.key});

  @override
  State<SignUpProfilePicView> createState() => _SignUpProfilePicViewState();
}

class _SignUpProfilePicViewState extends State<SignUpProfilePicView> {
  late Size _deviceSize;
  final int _currentStep = 2;

  // Controllers
  final _signUpController = Get.find<SignUpController>();

  @override
  void initState() {
    super.initState();
    _signUpController.clearProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;
    return AppScaffold(
      deviceSize: _deviceSize,
      appBar: AppBar(),
      body: Column(
        children: [
          _viewTexts(),
          SizedBox(height: _deviceSize.height * 0.05),
          _picViewArea(),
          SizedBox(height: _deviceSize.height * 0.05),
          Expanded(child: _picUploadButtons()),
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
            'Profile picture',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Text(
            'Add a clear profile photo to make your profile more personal and recognizable.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Profile pic view area
  Widget _picViewArea() {
    return Obx(
      () => Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
              image: _signUpController.profileImage != null
                  ? DecorationImage(
                      image: FileImage(_signUpController.profileImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _signUpController.profileImage == null
                ? Icon(Icons.person, size: 50, color: AppTheme.primaryColor)
                : null,
          ),

          if (_signUpController.isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.textSecondaryColor.withAlpha(100),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cardColor, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                color: AppTheme.cardColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Picture pick up option buttons
  Widget _picUploadButtons() {
    return Column(
      children: [
        UploadOptionTile(
          icon: Icons.camera_alt,
          iconBgColor: AppTheme.textPrimaryColor.withAlpha(50),
          iconColor: AppTheme.primaryColor,
          title: "Take a photo",
          subtitle: "Use your camera",
          onTap: () => _signUpController.takePhoto(),
        ),
        SizedBox(height: _deviceSize.height * 0.015),
        UploadOptionTile(
          icon: Icons.photo_library,
          iconBgColor: AppTheme.textPrimaryColor.withAlpha(50),
          iconColor: AppTheme.secondaryColor,
          title: "Choose from gallery",
          subtitle: "Pick from your photos",
          onTap: () => _signUpController.pickFromGallery(),
        ),
      ],
    );
  }

  // Continue button
  Widget _goToNextStepButton() {
    return AppButton(
      label: 'Next Step',
      isLoading: false,
      onPressed: () => _goToNextStep(),
    );
  }

  // Next step button
  Future<void> _goToNextStep() async {
    if (_signUpController.profileImage == null) {
      AppSnackBar.error(
        title: "Profile Picture Required",
        message: "Please upload a profile picture to continue.",
        context: context,
      );
      return;
    }

    await _signUpController.setProfileImage();
  }
}
