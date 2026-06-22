import 'package:flutter/material.dart';

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}