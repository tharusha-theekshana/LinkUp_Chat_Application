import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/widgets/scaffold/app_scaffold.dart';
import 'package:link_up/features/auth/core/controllers/auth_controller.dart';
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

  final _controller = Get.find<AuthController>();

  final List<Widget> _pages = [
    const ChatPage(),
    const FriendsPage(),
    const FindFriendsPage(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      deviceSize: _deviceSize,
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
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

class FindFriendsPage extends StatelessWidget {
  const FindFriendsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Find Friends'));
}
