import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/widgets/scaffold/app_scaffold.dart';
import 'package:link_up/features/auth/core/controllers/auth_controller.dart';
import 'package:link_up/features/find_friends/views/find_friends_view.dart';
import 'package:link_up/features/profile/views/profile_view.dart';

import '../../../theme/app_theme.dart';
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
    const ChatPage(),
    const FriendsPage(),
    const FindFriendsView(),
    const ProfileView(),
  ];

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
        onTap: (i) => setState(() => _currentIndex = i),
        deviceSize: _deviceSize,
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Chat'));
}

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Friends'));
}
