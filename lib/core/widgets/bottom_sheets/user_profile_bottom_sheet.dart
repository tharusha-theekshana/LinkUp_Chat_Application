import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:link_up/core/widgets/buttons/app_button.dart';
import 'package:link_up/theme/app_theme.dart';

import '../../../features/auth/core/data/models/user_model.dart';

class UserProfileBottomSheet extends StatelessWidget {
  final UserModel user;

  const UserProfileBottomSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: deviceSize.height * 0.88),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _dragHandle(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  vertical: deviceSize.height * 0.02,
                  horizontal: deviceSize.width * 0.025,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _profileHeaderSection(context, user),
                    const SizedBox(height: 20),
                    _bioSection(theme, context, user),
                    const SizedBox(height: 16),
                    _contactSection(theme, context, user),
                    const SizedBox(height: 16),
                    _otherDetailsSection(theme, context, user),
                    const SizedBox(height: 24),
                    _closeButton(context)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom sheet drag bar
  Widget _dragHandle() {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(100),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Profile header section - profile pic, name , user name and status
  Widget _profileHeaderSection(BuildContext context, UserModel user) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: theme.colorScheme.primary.withAlpha(120),
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: user.photoUrl.isNotEmpty
                      ? Image.network(
                          user.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildFallbackAvatar(theme, user),
                        )
                      : _buildFallbackAvatar(theme, user),
                ),
              ),
              if (user.isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _capitalizeWords(user.fullName),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.cardColor,
                        ),
                      ),
                    ),
                    if (user.isPremiumUser) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user.userName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.cardColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _statusChip(
                      theme: theme,
                      label: user.isOnline ? 'Online' : 'Offline',
                      color: user.isOnline
                          ? AppTheme.successColor
                          : AppTheme.textSecondaryColor,
                    ),
                    if (user.isPremiumUser)
                      _statusChip(
                        theme: theme,
                        label: 'Premium',
                        color: AppTheme.warningColor,
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

  // Profile pic loading error
  Widget _buildFallbackAvatar(ThemeData theme, UserModel user) {
    final initial = user.fullName.trim().isNotEmpty
        ? user.fullName.trim()[0]
        : '?';
    return Container(
      color: AppTheme.textSecondaryColor,
      alignment: Alignment.center,
      child: Text(
        initial.toUpperCase(),
        style: theme.textTheme.headlineMedium!.copyWith(
          fontSize: 28,
          color: AppTheme.cardColor,
        ),
      ),
    );
  }

  // Bio details section
  Widget _bioSection(ThemeData theme, BuildContext context, UserModel user) {
    return Text(
      textAlign: TextAlign.center,
      user.bio,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.textSecondaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Contact details section
  Widget _contactSection(
    ThemeData theme,
    BuildContext context,
    UserModel user,
  ) {
    return _sectionCard(
      context,
      title: 'Contact',
      child: Column(
        children: [
          _infoTile(
            context,
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: user.email,
          ),
          Divider(height: 1, color: Colors.grey.withAlpha(40)),
          _infoTile(
            context,
            icon: Icons.phone_rounded,
            label: 'Mobile',
            value: user.mobile,
          ),
        ],
      ),
    );
  }

  // Other details section
  Widget _otherDetailsSection( ThemeData theme,
      BuildContext context,
      UserModel user,){
    return _sectionCard(
      context,
      title: 'Details',
      child: Column(
        children: [
          _infoTile(
            context,
            icon: Icons.cake_rounded,
            label: 'Date of Birth',
            value: user.dob,
          ),
          Divider(height: 1, color: Colors.grey.withAlpha(40)),
          _infoTile(
            context,
            icon: Icons.event_available_rounded,
            label: 'Joined',
            value: DateFormat('dd MMM yyyy').format(user.createdAt),
          ),
          Divider(height: 1, color: Colors.grey.withAlpha(40)),
          _infoTile(
            context,
            icon: user.isOnline
                ? Icons.circle
                : Icons.access_time_rounded,
            label: 'Last seen',
            value: user.isOnline
                ? 'Online now'
                : user.lastSeen.toString(),
            valueColor: user.isOnline
                ? const Color(0xFF22C55E)
                : null,
          ),
        ],
      ),
    );
  }

  // Status chip - Online status
  Widget _statusChip({
    required ThemeData theme,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall!.copyWith(
          color: AppTheme.cardColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context){
    return AppButton(
        height: 45,
        label: "Close", onPressed: () => Get.back());
  }

  Widget _sectionCard(
    BuildContext context, {
    String? title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor == theme.scaffoldBackgroundColor
            ? Colors.grey.withAlpha(18)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodySmall?.color?.withAlpha(160),
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 19, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Capitalize name
  String _capitalizeWords(String text) {
    if (text.trim().isEmpty) return text;

    return text
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) => word.isEmpty
        ? word
        : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
