import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class DividerText extends StatelessWidget {
  final String text;

  const DividerText({super.key, this.text = 'OR'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppTheme.textSecondaryColor.withAlpha(150),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: Theme.of(context).textTheme.displaySmall),
        ),
        Expanded(
          child: Divider(
            color: AppTheme.textSecondaryColor.withAlpha(150),
            thickness: 0.5,
          ),
        ),
      ],
    );
  }
}
