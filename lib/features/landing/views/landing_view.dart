import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/widgets/scaffold/app_scaffold.dart';
import 'package:link_up/features/auth/core/controllers/auth_controller.dart';
import 'package:link_up/features/chats/views/chats_view.dart';
import 'package:link_up/features/find_friends/controllers/find_friends_controller.dart';
import 'package:link_up/features/find_friends/views/find_friends_view.dart';
import 'package:link_up/features/friends/views/friends_view.dart';
import 'package:link_up/features/profile/views/profile_view.dart';

import '../../../core/enums/request_tab.dart';
import '../../../theme/app_theme.dart';
import '../../friends/controllers/friends_controller.dart';
import '../widgets/bottom_nav_bar.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  late Size _deviceSize;
  int _currentIndex = 0;

  final List<String> _titles = ['Chats', 'Friends', 'Find Friends', 'Profile'];

  final List<Widget> _pages = [
    const ChatsView(),
    const FriendsView(),
    const FindFriendsView(),
    const ProfileView(),
  ];

  // Controllers
  final _friendsController = Get.find<FriendsController>();
  final _findFriendsController = Get.find<FindFriendsController>();


  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      deviceSize: _deviceSize,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        deviceSize: _deviceSize,
      ),
    );
  }

  void _onNavTap(int index) {
    if (_currentIndex == 1 && index != 1) {
      _friendsController.setSelectedTab = RequestTab.friends;
      _friendsController.clearSearch();
    }

    if (_currentIndex == 2 && index != 2) {
      _findFriendsController.clearSearch();
    }

    setState(() => _currentIndex = index);
  }
}
