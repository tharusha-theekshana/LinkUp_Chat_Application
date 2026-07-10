import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../core/widgets/avatars/user_pic_avatar.dart';
import '../../../core/widgets/buttons/small_app_button.dart';
import '../../../core/data/models/friend_request_model.dart';
import '../../auth/core/data/models/user_model.dart';

class ReceivedRequestDataRow extends StatelessWidget {
  final UserModel user;
  final FriendRequestModel request;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String Function(DateTime createdAt) getRequestTimeText;

  const ReceivedRequestDataRow({
    super.key,
    required this.user,
    required this.request,
    required this.onConfirm,
    required this.onCancel,
    required this.getRequestTimeText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserPicAvatar(user: user, radius: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "@${user.userName}",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      getRequestTimeText(request.createdAt),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: SmallAppButton(
                        label: "Delete",
                        backgroundColor: AppTheme.cardColor,
                        textColor: AppTheme.secondaryColor,
                        border: Border.all(color: AppTheme.textSecondaryColor.withAlpha(150)),
                        onPressed: onCancel,
                      ),
                    ),
                    Expanded(
                      child: SmallAppButton(
                        label: "Confirm",
                        backgroundColor: AppTheme.cardColor,
                        textColor: AppTheme.secondaryColor,
                        border: Border.all(color: AppTheme.textSecondaryColor.withAlpha(150)),
                        onPressed: onConfirm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}