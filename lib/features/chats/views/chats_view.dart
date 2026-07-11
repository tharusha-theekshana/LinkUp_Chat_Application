import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/enums/chat_filter.dart';
import '../../../core/widgets/text_field/app_text_field.dart';
import '../controllers/chat_controller.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  late Size _deviceSize;

  final _chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return Column(children: [_searchBar(),const SizedBox(height: 8),
      _filterTabs(),]);
  }

  // Search Bar
  Widget _searchBar() {
    return AppTextField(
      controller: _chatController.searchTextController,
      label: "",
      hintText: "Search Chats",
      prefixIcon: Icons.search,
      onChanged: (value) => _chatController.searchUserByName(
        name: _chatController.searchTextController.text,
      ),
    );
  }

  // WhatsApp-style filter tabs
// WhatsApp-style filter tabs
  Widget _filterTabs() {
    return Obx(() {
      final activeFilter = _chatController.activeFilter;
      final unreadCount = _chatController.getUnreadCount();

      return SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            _filterChip(
              label: "All",
              filter: ChatFilter.all,
              isActive: activeFilter == ChatFilter.all,
            ),
            const SizedBox(width: 8),
            _filterChip(
              label: unreadCount > 0 ? "Unread ($unreadCount)" : "Unread",
              filter: ChatFilter.unread,
              isActive: activeFilter == ChatFilter.unread,
            ),
            const SizedBox(width: 8),
            _filterChip(
              label: "Active",
              filter: ChatFilter.active,
              isActive: activeFilter == ChatFilter.active,
            ),
            const SizedBox(width: 8),
            _filterChip(
              label: "Recent",
              filter: ChatFilter.recent,
              isActive: activeFilter == ChatFilter.recent,
            ),
          ],
        ),
      );
    });
  }

  Widget _filterChip({
    required String label,
    required ChatFilter filter,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _chatController.setFilter(filterType: filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF075E54) // WhatsApp green
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
