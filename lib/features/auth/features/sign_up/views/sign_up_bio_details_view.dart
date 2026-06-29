import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../theme/app_theme.dart';
import '../../../../../core/enums/alert_type.dart';
import '../../../../../core/widgets/alert_dialogs/app_alert_dialogs.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/date_picker/app_date_picker.dart';
import '../../../../../core/widgets/scaffold/app_scaffold.dart';
import '../../../../../core/widgets/text_field/app_text_field.dart';
import '../../../core/widgets/step_indicator.dart';
import '../../../core/data/entities/user_data_entity.dart';
import '../controllers/sign_up_controller.dart';
import '../../../core/controllers/auth_controller.dart';

class SignUpBioDetailsView extends StatefulWidget {
  const SignUpBioDetailsView({super.key});

  @override
  State<SignUpBioDetailsView> createState() => _SignUpBioDetailsViewState();
}

class _SignUpBioDetailsViewState extends State<SignUpBioDetailsView> {
  late Size _deviceSize;
  final int _currentStep = 3;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _bioController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _selectedDate;

  // Controllers
  final _authController = Get.find<AuthController>();
  final _signUpController = Get.find<SignUpController>();

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery
        .of(context)
        .size;

    return AppScaffold(
      deviceSize: _deviceSize,
      appBar: AppBar(),
      body: Column(
        children: [
          _viewTexts(),
          SizedBox(height: _deviceSize.height * 0.025),
          Expanded(child: _formArea()),
          StepIndicator(totalSteps: 4, currentStep: _currentStep),
          SizedBox(height: _deviceSize.height * 0.015),
          _finishStepButton(),
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
            'Your Profile',
            style: Theme
                .of(
              context,
            )
                .textTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: _deviceSize.height * 0.015),
          Text(
            'Add a short bio so people know who you are. You can always update this later.',
            style: Theme
                .of(context)
                .textTheme
                .bodySmall,
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
            controller: _bioController,
            label: 'Bio',
            hintText: 'Hey there! I\'m using LinkUp',
            prefixIcon: Icons.edit_note_rounded,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            maxLength: 100,
            showCounter: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bio is required';
              }
              if (value.length > 100) {
                return 'Bio must be 100 characters or less';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          AppDatePicker(
            controller: _dobController,
            label: 'Date of birth',
            hintText: 'Select your date of birth',
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Date of birth is required';
              }
              return null;
            },
          ),
          SizedBox(height: _deviceSize.height * 0.02),
          _bioSuggestions(),
        ],
      ),
    );
  }

  // Quick-tap bio suggestion chips
  Widget _bioSuggestions() {
    final List<String> suggestions = [
      "Hey there! I'm using LinkUp 🔗",
      "Available ✅",
      "Busy 🙏",
      "At work 💼",
      "At the gym 💪",
      "In a meeting 🤫",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Quick suggestions',
            style: Theme
                .of(
              context,
            )
                .textTheme
                .displaySmall!
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            final bool isSelected = _bioController.text == suggestion;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _bioController.text = suggestion;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withAlpha(100),
                    width: 0.8,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 10,
                    vertical: 1,
                  ),
                  child: Text(
                    suggestion,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(
                      color: isSelected
                          ? AppTheme.cardColor
                          : AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Register button
  Widget _finishStepButton() {
    return Obx(
          () =>
          AppButton(
            label: 'I\'m Ready',
            isLoading: _authController.isLoading,
            onPressed: () => _finishSetup(),
          ),
    );
  }

  // Finish steps function
  Future<void> _finishSetup() async {
    if (_formKey.currentState!.validate()) {
      if (!_isAgeValid(_selectedDate!)) {
        return Get.dialog(
          AppAlertDialog(
            title: "Age Restriction",
            message:
            "You must be at least 13 years old to create a LinkUp account.",
            type: AlertType.restriction,
            buttonText: "Got It",
          ),
        );
      }

      await _signUpController.setBioData(
        bio: _bioController.text,
        dob: _dobController.text,
      );

      UserDataEntity userDataEntity = UserDataEntity(
          fullName: _signUpController.fullName,
          userName: _signUpController.userName,
          email: _signUpController.email,
          password: _signUpController.password,
          mobile: _signUpController.mobile,
          profilePic: _signUpController.profileImage!,
          bio: _signUpController.bio,
          dob: _signUpController.dateOfBirth);

      await _signUpController.sendRegisterDataToAuth(userData: userDataEntity);

    } else {
      Get.log("Form is not valid");
    }
  }

  // Returns true if the user is 13 or older
  bool _isAgeValid(DateTime dob) {
    final DateTime today = DateTime.now();
    final DateTime thirteenYearsAgo = DateTime(
      today.year - 13,
      today.month,
      today.day,
    );
    return dob.isBefore(thirteenYearsAgo) ||
        dob.isAtSameMomentAs(thirteenYearsAgo);
  }
}
