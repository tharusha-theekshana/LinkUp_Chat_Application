import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../enums/app_button_type.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonType type;
  final IconData? icon;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final TextStyle? labelStyle;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.type = AppButtonType.primary,
    this.icon,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
    this.labelStyle,
  });

  static const Color _primaryColor = AppTheme.primaryColor;

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading || onPressed == null;

    final TextStyle defaultLabelStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
    fontWeight: FontWeight.bold,
    color: AppTheme.backgroundColor
    );

    final TextStyle effectiveLabelStyle = defaultLabelStyle.merge(labelStyle);

    Widget child = isLoading
        ? SizedBox(
      height: 15,
      width: 15,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(
          type == AppButtonType.primary
              ? AppTheme.backgroundColor
              : _primaryColor,
        ),
      ),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: effectiveLabelStyle,
        ),
      ],
    );

    final ButtonStyle style = switch (type) {
      AppButtonType.primary => ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? _primaryColor,
        foregroundColor: textColor ?? AppTheme.cardColor,
        disabledBackgroundColor: (backgroundColor ?? _primaryColor)
            .withOpacity(0.5),
        disabledForegroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      AppButtonType.outlined => OutlinedButton.styleFrom(
        foregroundColor: textColor ?? _primaryColor,
        side: BorderSide(
          color: (backgroundColor ?? _primaryColor)
              .withOpacity(disabled ? 0.4 : 1),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      AppButtonType.text => TextButton.styleFrom(
        foregroundColor: textColor ?? _primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    };

    final button = switch (type) {
      AppButtonType.primary => ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: style,
        child: child,
      ),
      AppButtonType.outlined => OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: style,
        child: child,
      ),
      AppButtonType.text => TextButton(
        onPressed: disabled ? null : onPressed,
        style: style,
        child: child,
      ),
    };

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: button,
    );
  }
}