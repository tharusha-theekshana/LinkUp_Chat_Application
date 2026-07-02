import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class PillButton extends StatelessWidget {
  final Size deviceSize;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const PillButton({
    super.key,
    required this.deviceSize,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgSelectedColor = selectedColor ?? AppTheme.primaryColor;
    final bgUnselectedColor =
        unselectedColor ?? AppTheme.secondaryColor.withAlpha(50);

    final textSelectedColor = selectedTextColor ?? AppTheme.cardColor;
    final textUnselectedColor =
        unselectedTextColor ?? AppTheme.textPrimaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        width: 100,
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? bgSelectedColor : bgUnselectedColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? textSelectedColor : textUnselectedColor,
            ),
          ),
        ),
      ),
    );
  }
}
