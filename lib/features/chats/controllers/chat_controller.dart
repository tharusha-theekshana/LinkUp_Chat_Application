import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:link_up/core/data/models/chat_model.dart';
import 'package:link_up/core/data/models/notification_model.dart';
import 'package:link_up/core/enums/chat_filter.dart';
import 'package:link_up/routes/app_routes.dart';

import '../../../core/services/firestore_service.dart';
import '../../auth/core/controllers/auth_controller.dart';
import '../../auth/core/data/models/user_model.dart';

class ChatController extends GetxController {
  final _firestoreService = Get.find<FirestoreService>();
  final _authController = Get.find<AuthController>();

  // Form controller
  final searchTextController = TextEditingController();

  // For chats
  final RxList<ChatModel> _allChats = RxList<ChatModel>([]);
  final RxList<ChatModel> _filteredChats = RxList<ChatModel>([]);
  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<String> _searchQuery = Rx<String>("");
  final Rx<bool> _isSearching = Rx<bool>(false);
  final RxMap<String, UserModel> _users = RxMap<String, UserModel>({});
  final Rx<ChatFilter> _activeFilter = Rx<ChatFilter>(ChatFilter.all);

  List<ChatModel> get allChats => _allChats.toList();

  List<ChatModel> get filteredChats => _filteredChats.toList();

  bool get isLoading => _isLoading.value;

  String get searchQuery => _searchQuery.value;

  bool get isSearching => _isSearching.value;

  Map<String, UserModel> get users => _users;

  ChatFilter get activeFilter => _activeFilter.value;

  @override
  void onInit() {
    super.onInit();
    _loadChats();
    _loadUsers();
  }

  void _loadChats() {
    final currentUserId = _authController.user?.uid;

    _allChats.bindStream(
        _firestoreService.getUserChatStream(userId: currentUserId!));

    ever(_allChats, (_) {
      if (_isSearching.value && _searchQuery.value.isNotEmpty) {
        _performSearch(_searchQuery.value);
      }
    },);

    ever(_activeFilter, (_) {
      if (_searchQuery.value.isNotEmpty) {
        _performSearch(_searchQuery.value);
      }
    },);
  }

  // Load all users
  void _loadUsers() async {
    _users.bindStream(
      _firestoreService.getAllUsersStream().map((userList) {
        Map<String, UserModel> userMap = {};

        for (var user in userList) {
          userMap[user.id] = user;
        }

        return userMap;
      }),
    );
  }

  UserModel? getOtherUser({required ChatModel chat}) {
    final currentUserId = _authController.user?.uid;

    final otherUserId = chat.getOtherParticipants(currentUserId!);
    return _users[otherUserId];
  }

  String formatLastMessageType({required DateTime? time}) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays}d ago';
    } else {
      return 'Last seen ${time.day}/${time.month}/${time.year}';
    }
  }

  List<ChatModel> _getFilteredChats() {
    List<ChatModel> baseList = _isSearching.value ? _filteredChats : _allChats;

    switch (_activeFilter.value) {
      case ChatFilter.unread :
        return _applyUnreadFilter(baseList);
      case ChatFilter.recent :
        return _applyRecentFilter(baseList);
      case ChatFilter.active :
        return _applyActiveFilter(baseList);
      case ChatFilter.all :
        return baseList;
    }
  }

  List<ChatModel> _applyUnreadFilter(List<ChatModel> baseList) {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return [];

    return baseList.where((chat) => chat.getUnreadCount(currentUserId) > 0,)
        .toList();
  }

  List<ChatModel> _applyRecentFilter(List<ChatModel> baseList) {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(Duration(days: 3));

    return baseList.where((chat) {
      if (chat.lastMessageTime == null) return false;
      return chat.lastMessageTime!.isAfter(threeDaysAgo);
    })
        .toList();
  }

  List<ChatModel> _applyActiveFilter(List<ChatModel> baseList) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));

    return baseList.where((chat) {
      if (chat.lastMessageTime == null) return false;
      return chat.lastMessageTime!.isAfter(oneWeekAgo);
    })
        .toList();
  }

  void setFilter({required ChatFilter filterType}) {
    _activeFilter.value = filterType;

    if (filterType == ChatFilter.all) {
      if (_searchQuery.value.isEmpty) {
        _isSearching.value = false;
        _filteredChats.clear();
      }
    }
  }

  void cleaAllFilters() {
    _activeFilter.value = ChatFilter.all;
    _clearSearch();
  }

  void onSearchChanged({required String query}) {
    _searchQuery.value = query;

    if (query.isEmpty) {
      _clearSearch();
    } else {
      _isSearching.value = true;
      _performSearch(query);
    }
  }

  void _performSearch(String query) {
    final lowerCaseQuery = query.toLowerCase().trim();

    _filteredChats.value = _allChats.where((chat) {
      final otherUser = getOtherUser(chat: chat);
      if (otherUser == null) return false;

      final displayNameMatch = otherUser.fullName.toLowerCase().contains(
          lowerCaseQuery) ?? false;

      return displayNameMatch;
    },).toList();
  }

  void _sortSearchResults({required String query}) {
    filteredChats.sort((a, b) {
      final userA = getOtherUser(chat: a);
      final userB = getOtherUser(chat: b);

      if (userA == null || userB == null) return 0;

      final extractMatchA = userA.fullName.toLowerCase().startsWith(query) ??
          false;
      final extractMatchB = userB.fullName.toLowerCase().startsWith(query) ??
          false;

      if (extractMatchA && !extractMatchB) return -1;
      if (!extractMatchA && extractMatchB) return 1;

      return (b.lastMessageTime ?? DateTime(0)).compareTo(
          a.lastMessageTime ?? DateTime(0));
    }
    );
  }

  void _clearSearch() {
    _isSearching.value = false;
    _filteredChats.clear();
  }

  void clearSearch() {
    _searchQuery.value = '';
    _clearSearch();
  }

  void searchUserByName({required String name}) {
    onSearchChanged(query: name);
  }

  void searchByLastMessage({required String message}) {
    onSearchChanged(query: message);
  }

  List<ChatModel> getUnreadChats() {
    return _applyUnreadFilter(_allChats);
  }

  List<ChatModel> getActiveChats() {
    return _applyActiveFilter(_allChats);
  }

  List<ChatModel> getRecentChats({int limit = 10}) {
    final recentChats = _applyRecentFilter(_allChats);

    final sortedChats = List<ChatModel>.from(recentChats);
    sortedChats.sort((a, b) {
      return (b.lastMessageTime ?? DateTime(0)).compareTo(
          a.lastMessageTime ?? DateTime(0));
    },);

    return sortedChats.take(limit).toList();
  }

  int getUnreadCount() {
    return getUnreadChats().length;
  }

  int getRecentCount() {
    return getRecentChats().length;
  }

  int getActiveCount() {
    return getActiveChats().length;
  }

  List<String> getSearchSuggestions() {
    final suggestions = <String>[];

    for (var chat in _allChats) {
      final otherUser = getOtherUser(chat: chat);

      if (otherUser?.fullName != null) {
        suggestions.add(otherUser!.fullName);
      }
    }

    return suggestions.toSet().toList();
  }

  void openChat({required ChatModel chat}) {
    final otherUser = getOtherUser(chat: chat);

    if (otherUser != null) {
      Get.toNamed(AppRoutes.chat,
          arguments: {'chatId': chat.id, 'otherUser': otherUser});
    }
  }

  int getTotalUnreadCount(){
    final currentUserId = _authController.user?.uid;
    if(currentUserId == null) return 0;

    int total = 0;
    for(var chat in _allChats){
      total += chat.getUnreadCount(currentUserId);
    }

    return total;
  }

  Future<void> deleteChat({required ChatModel chat}) async {
    try{
      final currentUserId = _authController.user?.uid;
      if(currentUserId == null) return;

      final otherUser = getOtherUser(chat: chat);
      await _firestoreService.deleteChatForUser(chatId: chat.id, userId: currentUserId);

    }catch(e){

    }
  }
}