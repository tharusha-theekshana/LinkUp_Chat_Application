import 'package:flutter/material.dart';

class SmallAppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final TextStyle? labelStyle;
  final double elevation;
  final BoxBorder? border;

  const SmallAppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 32,
    this.borderRadius = 6,
    this.labelStyle,
    this.elevation = 1,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(borderRadius),
        color: backgroundColor ?? Theme.of(context).primaryColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: SizedBox(
            height: height,
            child: Center(
              child: Text(
                label,
                style: labelStyle ??
                    TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}