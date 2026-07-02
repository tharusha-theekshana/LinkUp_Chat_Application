import 'package:flutter/material.dart';
import 'package:link_up/features/auth/core/data/models/user_model.dart';

import '../../../theme/app_theme.dart';

class UserPicAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;

  const UserPicAvatar({super.key, required this.user, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppTheme.textSecondaryColor.withAlpha(150),
          backgroundImage: NetworkImage(user.photoUrl),
        ),
        if (user.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
