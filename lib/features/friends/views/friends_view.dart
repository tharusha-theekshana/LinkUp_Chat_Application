import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/enums/request_tab.dart';
import 'package:link_up/features/find_friends/controllers/find_friends_controller.dart';
import 'package:link_up/features/friends/controllers/friends_controller.dart';
import 'package:link_up/features/friends/widgets/pill_button.dart';

import '../../../core/widgets/buttons/small_app_button.dart';
import '../../../core/widgets/text_field/app_text_field.dart';
import '../../../core/widgets/views/empty_state_view.dart';
import '../widgets/sent_request_data_row.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  late Size _deviceSize;

  final _friendsController = Get.find<FriendsController>();
  final _findFriendsController = Get.find<FindFriendsController>();

  
  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return Column(
      children: [
        _requestTabSelector(),
        SizedBox(height: _deviceSize.height * 0.002),
        _searchBar(),
        SizedBox(height: _deviceSize.height * 0.02),
        _dataListLengthText(),
        SizedBox(height: _deviceSize.height * 0.005),
        _dataListArea(),
      ],
    );
  }

  Widget _requestTabSelector() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PillButton(
            deviceSize: _deviceSize,
            label: 'Your Friends',
            isSelected: _friendsController.selectedTab == RequestTab.friends,
            onTap: () {
              _friendsController.clearSearch();
              _friendsController.setSelectedTab = RequestTab.friends;
            },
          ),
          const SizedBox(width: 5),
          PillButton(
            deviceSize: _deviceSize,
            label: 'Friend Requests',
            isSelected:
                _friendsController.selectedTab == RequestTab.receivedRequests,
            onTap: () {
              _friendsController.clearSearch();
              _friendsController.setSelectedTab = RequestTab.receivedRequests;
            },
          ),
          const SizedBox(width: 5),
          PillButton(
            deviceSize: _deviceSize,
            label: 'Sent Requests',
            isSelected:
                _friendsController.selectedTab == RequestTab.sendRequests,
            onTap: () {
              _friendsController.clearSearch();
              _friendsController.setSelectedTab = RequestTab.sendRequests;
            },
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _searchBar() {
    return Obx(() {
      final tab = _friendsController.selectedTab;
      String hintText;

      switch (tab) {
        case RequestTab.friends:
          hintText = "Search Friends";
          break;

        case RequestTab.receivedRequests:
          hintText = "Search Requests";
          break;

        case RequestTab.sendRequests:
          hintText = "Search Requests";
          break;
      }

      return AppTextField(
        controller: _friendsController.searchTextController,
        label: "",
        hintText: hintText,
        prefixIcon: Icons.search,
        onChanged: (value) =>
            _friendsController.updateSearchQuery(query: value, requestTab: tab),
      );
    });
  }

  // Data list length text
  Widget _dataListLengthText() {
    return Obx(() {
      final int count;
      final String label;

      switch (_friendsController.selectedTab) {
        case RequestTab.friends:
          count = _friendsController.filteredFriends.length;
          label = "Friend";
          break;

        case RequestTab.receivedRequests:
          count = 0;
          label = "Request";
          break;

        case RequestTab.sendRequests:
          count = _friendsController.filteredSentFriendRequests.length;
          label = "Request";
          break;
      }

      return Align(
          alignment: Alignment.topRight,
          child: Text("$count $label${count == 1 ? '' : 's'}",style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.bold
          )));
    });
  }

  // Data list area
  Widget _dataListArea() {
    return Expanded(
      child: Obx(() {
        switch (_friendsController.selectedTab) {
          case RequestTab.friends:
            return _friendsListView();

          case RequestTab.receivedRequests:
            return _receivedRequestsView();

          case RequestTab.sendRequests:
            return _sentRequestsView();
        }
      }),
    );
  }

  // Friend list view
  Widget _friendsListView() {
    return Obx(() {
      if (_friendsController.allFriends.isEmpty) {
        return const Center(child: Text("No friends yet"));
      }

      return ListView.builder(
        itemCount: _friendsController.allFriends.length,
        itemBuilder: (context, index) {
          final user = _friendsController.allFriends[index];

          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
            title: Text(user.fullName),
            subtitle: Text(user.email),
          );
        },
      );
    });
  }

  Widget _receivedRequestsView() {
    return Center(
      child: Text(
        "📥 Friend Requests Received",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Sent requests list view
  Widget _sentRequestsView() {
    return Obx(() {
      if (_friendsController.sentFriendRequests.isEmpty) {
        return EmptyStateView(
          imageAsset: 'assets/images/icons/no_request_icon.png',
          title: "No Requests",
          subtitle: "Requests you send to others will show up here.",

        );
      }

      if (_friendsController.filteredSentFriendRequests.isEmpty) {
        return const EmptyStateView(
          imageAsset: 'assets/images/icons/empty_data.png',
          title: "Nothing Found",
          subtitle: "We couldn't find anyone matching your search.",
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 2),
        itemCount: _friendsController.filteredSentFriendRequests.length,
        itemBuilder: (context, index) {
          final friendRequest =
              _friendsController.filteredSentFriendRequests[index];
          final user = _friendsController.getUser(
            userId: friendRequest.receiverId,
          );

          return SentRequestDataRow(
            user: user,
            request: friendRequest,
            onCancel: () => _findFriendsController.cancelFriendRequest(user: user),
            getRequestTimeText: (createdAt) =>
                _friendsController.getRequestTimeText(createdAt: createdAt),
          );
        },
      );
    });
  }
}
