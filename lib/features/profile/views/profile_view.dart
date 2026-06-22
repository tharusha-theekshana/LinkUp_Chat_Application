import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/features/profile/widgets/action_tile.dart';
import 'package:link_up/features/profile/widgets/info_card.dart';
import 'package:link_up/features/profile/widgets/info_row.dart';
import 'package:link_up/theme/app_theme.dart';

import '../../../../../core/widgets/scaffold/app_scaffold.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Size _deviceSize;
  final _profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      deviceSize: _deviceSize,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _topLevelSection(),
            SizedBox(height: _deviceSize.height * 0.028),
            _actionIcons(),
            SizedBox(height: _deviceSize.height * 0.028),
            _infoSection(),
            SizedBox(height: _deviceSize.height * 0.03),
            _accountActions(),
            SizedBox(height: _deviceSize.height * 0.02),
          ],
        ),
      ),
    );
  }

  // Top level widgets with profile pic and other details
  Widget _topLevelSection() {
    return Obx(
      () => Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage:
                    _profileController.currentUser?.photoUrl.isNotEmpty == true
                    ? NetworkImage(_profileController.currentUser!.photoUrl)
                    : null,
                child: _profileController.currentUser?.photoUrl.isEmpty ?? true
                    ? Text(
                        _getInitials(),
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                      )
                    : null,
              ),
              Positioned(bottom: 2, right: 2, child: _onlineStatusBadge()),
            ],
          ),
          SizedBox(height: _deviceSize.height * 0.02),
          _onlineStatusLabel(),
          SizedBox(height: _deviceSize.height * 0.02),
          Text(
            _profileController.fullNameController.text,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontSize: 20),
          ),
          SizedBox(height: _deviceSize.height * 0.008),
          Text(
            _profileController.email,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    );
  }

  // Online status badge circle view
  Widget _onlineStatusBadge() {
    final isOnline = _profileController.currentUser?.isOnline ?? false;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isOnline ? AppTheme.successColor : AppTheme.warningColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2.5,
        ),
      ),
    );
  }

  // Online status badge text view (online or offline)
  Widget _onlineStatusLabel() {
    final isOnline = _profileController.currentUser?.isOnline ?? false;
    final color = isOnline ? AppTheme.successColor : AppTheme.warningColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        isOnline ? 'Online' : 'Offline',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // User info section
  Widget _infoSection() {
    return Obx(() {
      final user = _profileController.currentUser;
      return Column(
        children: [
          InfoCard(
            label: 'identity',
            children: [
              InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Full name',
                value: user?.fullName,
              ),
              InfoRow(
                icon: Icons.alternate_email_rounded,
                label: 'Username',
                value: user?.userName.isNotEmpty == true
                    ? '@${user!.userName}'
                    : null,
              ),
              InfoRow(
                icon: Icons.cake_outlined,
                label: 'Date of birth',
                value: user?.dob,
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoCard(
            label: 'contact',
            children: [
              InfoRow(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: user?.email,
              ),
              InfoRow(
                icon: Icons.phone,
                label: 'Phone',
                value: user?.mobile,
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoCard(
            label: 'ABOUT',
            children: [InfoRow(
              icon:   Icons.edit_note_rounded,
              label: 'Bio',
              value: user?.bio,
            ),],
          ),
        ],
      );
    });
  }

  Widget _actionIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _actionIconButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Message',
          onTap: () {
            // TODO: implement message
          },
        ),
        SizedBox(width: _deviceSize.width * 0.08),
        _actionIconButton(
          icon: Icons.call_outlined,
          label: 'Call',
          onTap: () {
            // TODO: implement voice call
          },
        ),
        SizedBox(width: _deviceSize.width * 0.08),
        _actionIconButton(
          icon: Icons.videocam_outlined,
          label: 'Video',
          onTap: () {
            // TODO: implement video call
          },
        ),
      ],
    );
  }

  Widget _actionIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withAlpha(50),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _accountActions() {
    return Column(
      children: [
        ActionTile(
          icon: Icons.logout_rounded,
          label: 'Sign Out',
          onTap: _profileController.signOut,
        ),
        const SizedBox(height: 10),
        ActionTile(
          icon: Icons.delete_outline_rounded,
          label: 'Delete Account',
          color: Colors.red,
          onTap: _profileController.deleteAccount,
        ),
      ],
    );
  }

  String _getInitials() {
    final first = _profileController.fullNameController.text;
    final last = _profileController.userNameController.text;
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }
}
