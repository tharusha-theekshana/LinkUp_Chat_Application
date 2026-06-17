import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final double activeWidth;
  final double dotSize;
  final double spacing;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = AppTheme.primaryColor,
    this.inactiveColor = AppTheme.textSecondaryColor,
    this.activeWidth = 20,
    this.dotSize = 8,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final bool isActive = index == currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? activeWidth : dotSize,
          height: dotSize - 3,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}