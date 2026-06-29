import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Size deviceSize;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.deviceSize
  });

  static const _items = [
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chat', hasNotif: false),
    (icon: Icons.people_outline_rounded, label: 'Friends', hasNotif: false),
    (icon: Icons.person_search_outlined, label: 'Find', hasNotif: false),
    (icon: Icons.person_outline_rounded, label: 'Profile', hasNotif: false),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        bottomInset + 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.10), width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final active = i == currentIndex;
            final color = active
                ? AppTheme.cardColor
                : AppTheme.textSecondaryColor;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(item.icon, color: color, size: 24),
                        if (item.hasNotif)
                          Positioned(
                            top: -2,
                            right: -4,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.secondaryColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: active ? 20 : 0,
                      height: active ? 3 : 0,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
