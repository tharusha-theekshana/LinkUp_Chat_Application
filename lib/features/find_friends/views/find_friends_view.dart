import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/widgets/bottom_sheets/user_profile_bottom_sheet.dart';

import '../../../theme/app_theme.dart';
import '../../../core/enums/user_relationship_status.dart';
import '../../../core/widgets/avatars/user_pic_avatar.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/buttons/small_app_button.dart';
import '../../../core/widgets/loader/app_loader.dart';
import '../../../core/widgets/text_field/app_text_field.dart';
import '../../auth/core/data/models/user_model.dart';
import '../controllers/find_friends_controller.dart';

class FindFriendsView extends StatefulWidget {
  const FindFriendsView({super.key});

  @override
  State<FindFriendsView> createState() => _FindFriendsViewState();
}

class _FindFriendsViewState extends State<FindFriendsView> {
  late Size _deviceSize;

  // Controller
  final _findFriendsController = Get.find<FindFriendsController>();

  @override
  void dispose() {
    _findFriendsController.searchTextController.dispose();
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
      controller: _findFriendsController.searchTextController,
      label: "",
      hintText: "Search Friends",
      prefixIcon: Icons.search,
      onChanged: (value) =>
          _findFriendsController.updateSearchQuery(query: value),
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

      return ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, _) {
          return Container();
        },
        itemBuilder: (context, index) {
          final user = users[index];
          return _userDataTile(userData: user);
        },
      );
    });
  }

  // User data tile
  Widget _userDataTile({required UserModel userData}) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserPicAvatar(user: userData, radius: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData.fullName,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _findFriendsController.getLastSeenText(user: userData),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  _relationShipButtons(user: userData),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Relationship status buttons
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
                onPressed: () => Get.bottomSheet(UserProfileBottomSheet(user: user)),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: SmallAppButton(
                label: "Add Friend",
                backgroundColor: AppTheme.secondaryColor.withAlpha(200),
                onPressed: () =>
                    _findFriendsController.sendFriendRequest(user: user),
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
                onPressed: () =>
                    _findFriendsController.cancelFriendRequest(user: user),
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
