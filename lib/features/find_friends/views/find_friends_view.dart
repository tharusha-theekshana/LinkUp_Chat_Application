import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/enums/user_relationship_status.dart';
import 'package:link_up/core/widgets/buttons/app_button.dart';
import 'package:link_up/core/widgets/buttons/small_app_button.dart';
import 'package:link_up/core/widgets/loader/app_loader.dart';
import 'package:link_up/core/widgets/text_field/app_text_field.dart';
import 'package:link_up/features/auth/core/data/models/user_model.dart';

import '../../../theme/app_theme.dart';
import '../controllers/find_friends_controller.dart';

class FindFriendsView extends StatefulWidget {
  const FindFriendsView({super.key});

  @override
  State<FindFriendsView> createState() => _FindFriendsViewState();
}

class _FindFriendsViewState extends State<FindFriendsView> {
  late Size _deviceSize;
  final TextEditingController _searchTextController = TextEditingController();

  // Controller
  final _findFriendsController = Get.find<FindFriendsController>();

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return Column(
      children: [
        _searchBar(),
        SizedBox(height: _deviceSize.height * 0.03),
        Expanded(child: _friendsList()),
      ],
    );
  }

  // Search Bar
  Widget _searchBar() {
    return AppTextField(
      controller: _searchTextController,
      label: "",
      hintText: "Search Friends",
      prefixIcon: Icons.search,
      onChanged: (value) => _findFriendsController.updateSearchQuery(query: value)
    );
  }

  // Friends list
  Widget _friendsList() {
    return Obx(() {
      if (_findFriendsController.isLoading.value &&
          _findFriendsController.users.isEmpty) {
        return const Center(child: AppLoader());
      }

      final users = _findFriendsController.filteredUsers;

      if (users.isEmpty) {
        return const Center(
          child: Text('No users found', style: TextStyle(color: Colors.grey)),
        );
      }

      return ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_,_){
          return Container();
        },
        itemBuilder: (context, index) {
          final user = users[index];
          return _userDataTile(user);
        },
      );
    });
  }

  // User data tile
  Widget _userDataTile(UserModel user) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 25,right: 12,left: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(user),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _relationShipButtons(user: user),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Avatar area
  Widget _buildAvatar(UserModel user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 30,
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

  Widget _relationShipButtons({required UserModel user}) {
    final status = _findFriendsController.getUserRelationshipStatus(
      userId: user.id,
    );

    switch (status) {
      case UserRelationshipStatus.none:
        return Row(
          children: [
            Expanded(
              child: SmallAppButton(
                label: "View Profile",
                backgroundColor: AppTheme.textSecondaryColor.withAlpha(200),
                onPressed: () {},
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: SmallAppButton(
                label: "Add Friend",
                backgroundColor: AppTheme.secondaryColor.withAlpha(200),
                onPressed: () => _findFriendsController.sendFriendRequest(user: user),
              ),
            ),
          ],
        );

      case UserRelationshipStatus.friendRequestSent:
        return Row(
          children: [
            Expanded(
              child: SmallAppButton(
                label: "View Profile",
                backgroundColor: AppTheme.textSecondaryColor.withAlpha(200),
                onPressed: () {},
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: SmallAppButton(
                label: "Cancel Request",
                backgroundColor: AppTheme.primaryColor.withAlpha(200),
                onPressed: () => _findFriendsController.cancelFriendRequest(user: user),
              ),
            ),
          ],
        );

      case UserRelationshipStatus.friendRequestReceived:
        return Row(
          children: [
            Expanded(
              child: SmallAppButton(
                label: "Delete",
                backgroundColor: AppTheme.primaryColor.withAlpha(200),
                onPressed: () {},
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: SmallAppButton(
                label: "Confirm",
                backgroundColor: AppTheme.secondaryColor.withAlpha(200),
                onPressed: () {},
              ),
            ),
          ],
        );

      case UserRelationshipStatus.friends:
        return Row(
          children: [
            Expanded(
              child: SmallAppButton(
                label: "View Profile",
                backgroundColor: AppTheme.textSecondaryColor.withAlpha(200),
                onPressed: () {},
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: SmallAppButton(
                label: "Message",
                backgroundColor: AppTheme.secondaryColor.withAlpha(200),
                onPressed: () {},
              ),
            ),
          ],
        );

      case UserRelationshipStatus.blocked:
        return AppButton(label: "Unblock", onPressed: () {});
    }
  }
}
