import 'package:flutter/material.dart';
import 'package:link_up/theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const InfoCard({
    super.key,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryColor.withAlpha(75)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 5),
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondaryColor,
              )
            ),
          ),
          ..._buildChildren(context),
        ],
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final divider = Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(context).dividerColor.withAlpha(35),
      indent: 14,
      endIndent: 14,
    );
    return children.expand((child) => [
      divider,
      child,
    ]).toList();
  }
}