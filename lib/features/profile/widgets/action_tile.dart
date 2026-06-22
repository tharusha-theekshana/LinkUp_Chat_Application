import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(
        vertical: 0,
        horizontal: 0,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      onTap: onTap,
      leading: Icon(
        icon,
        size: 18,
        color: color,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color ?? theme.iconTheme.color,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.secondaryColor.withAlpha(120),
        ),
      ),
    );
  }
}