import 'package:flutter/material.dart';
import 'package:link_up/theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLength;
  final int maxLines;
  final bool enabled;
  final bool readOnly;
  final bool showCounter;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLength = 20,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.showCounter = false,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  Widget? get _suffixIcon {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
          color: AppTheme.textSecondaryColor,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        size: 20,
        color: AppTheme.textSecondaryColor,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          onEditingComplete: widget.onEditingComplete,
          style: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: AppTheme.textSecondaryColor),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: AppTheme.textSecondaryColor,
                  )
                : null,
            suffixIcon: _suffixIcon,
            filled: true,
            fillColor: widget.enabled ? AppTheme.cardColor : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            counterText: widget.showCounter ? null : "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textSecondaryColor,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textSecondaryColor,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.errorColor, width: 1.2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 0.5),
            ),
            errorStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.errorColor,
            ),
          ),
        ),
      ],
    );
  }
}
