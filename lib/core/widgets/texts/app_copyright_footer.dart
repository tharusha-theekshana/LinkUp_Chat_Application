import 'package:flutter/material.dart';

class AppCopyrightFooter extends StatelessWidget {
  final String companyName;
  final int? year;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const AppCopyrightFooter({
    super.key,
    this.companyName = 'CoderUX Technologies & IT Solutions',
    this.year,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final displayYear = year ?? DateTime.now().year;

    return Padding(
      padding: padding,
      child: Center(
        child: Text(
          '© $displayYear $companyName',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}