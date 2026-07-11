import 'package:flutter/material.dart';
import 'package:link_up/theme/app_theme.dart';

import '../../enums/alert_type.dart';

class AppAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final AlertType type;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Close',
    this.onPressed,
    this.type = AlertType.error,
  });

  static const Color _primaryColor = AppTheme.primaryColor;

  ({Color bg, Color fg, IconData icon}) get _iconStyle => switch (type) {
    AlertType.error => (
      bg: AppTheme.cardColor,
      fg: AppTheme.errorColor,
      icon: Icons.error_outline,
    ),
    AlertType.success => (
      bg: AppTheme.cardColor,
      fg: const Color(0xFF3B6D11),
      icon: Icons.check_circle_outline_rounded,
    ),
    AlertType.warning => (
      bg: AppTheme.cardColor,
      fg: const Color(0xFF854F0B),
      icon: Icons.warning_amber_rounded,
    ),
    AlertType.info => (
      bg: AppTheme.cardColor,
      fg: const Color(0xFF185FA5),
      icon: Icons.info_outline_rounded,
    ),
    AlertType.restriction => (
      bg: AppTheme.cardColor,
      fg: AppTheme.errorColor,
      icon: Icons.sentiment_dissatisfied,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final iconStyle = _iconStyle;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconStyle.fg.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(iconStyle.icon, color: iconStyle.fg, size: 28),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconStyle.bg,
                  foregroundColor: iconStyle.fg,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: iconStyle.fg
                    )
                  ),
                ),
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 12,
                    color: iconStyle.fg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
