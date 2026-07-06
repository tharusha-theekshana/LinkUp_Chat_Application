import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/data/models/friendship_model.dart';
import 'package:link_up/features/auth/core/data/models/user_model.dart';
import 'package:link_up/routes/app_routes.dart';

import '../../../core/data/models/friend_request_model.dart';
import '../../../core/enums/friend_request_status.dart';
import '../../../core/enums/request_tab.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/core/controllers/auth_controller.dart';

class FriendsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<String> _searchQuery = Rx<String>("");

  bool get isLoading => _isLoading.value;

  String get searchQuery => _searchQuery.value;

  // Form controller
  final searchTextController = TextEditingController();

  // Catch selected tab
  final Rxn<RequestTab> _selectedTab = Rxn<RequestTab>(RequestTab.friends);

  RequestTab get selectedTab => _selectedTab.value!;

  final RxList<FriendshipModel> _friendShips = RxList<FriendshipModel>([]);
  final RxList<UserModel> _allFriends = RxList<UserModel>([]);
  final RxList<UserModel> _filteredFriends = RxList<UserModel>([]);

  // For received friend requests
  final RxList<FriendRequestModel> _receivedFriendRequests =
      RxList<FriendRequestModel>([]);
  final RxList<FriendRequestModel> _filteredReceivedFriendRequests =
  RxList<FriendRequestModel>([]);

  List<FriendRequestModel> get friendRequests =>
      _receivedFriendRequests;
  RxList<FriendRequestModel> get filteredReceivedFriendRequests =>
      _filteredReceivedFriendRequests;

  // For sent friend request
  final RxList<FriendRequestModel> _sentFriendRequests =
      RxList<FriendRequestModel>([]);
  final RxList<FriendRequestModel> _filteredSentFriendRequests =
      RxList<FriendRequestModel>([]);

  RxList<FriendRequestModel> get sentFriendRequests => _sentFriendRequests;
  RxList<FriendRequestModel> get filteredSentFriendRequests =>
      _filteredSentFriendRequests;

  RxMap<String, UserModel> get users => _users;

  final RxMap<String, UserModel> _users = RxMap<String, UserModel>({});

  StreamSubscription? _friendshipsSubscriptions;

  List<FriendshipModel> get friendShips => _friendShips.toList();

  List<UserModel> get allFriends => _allFriends;

  List<UserModel> get filteredFriends => _filteredFriends;

  RxList<FriendRequestModel> get receivedFriendRequests =>
      _receivedFriendRequests;

  set setSelectedTab(RequestTab value) {
    _selectedTab.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    _loadAllFriends();
    _loadAllFriendRequests();
    _loadUsers();

    debounce(
      _searchQuery,
      (_) => _filterFriends(),
      time: Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _friendshipsSubscriptions?.cancel();
    super.onClose();
  }

  // Load all users
  void _loadAllFriends() async {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _friendshipsSubscriptions = _firestoreService
          .getFriendsStream(userId: currentUserId)
          .listen((friendshipList) {
            _friendShips.value = friendshipList;
            _loadFriendsDetails(
              currentUserId: currentUserId,
              friendshipList: friendshipList,
            );
          });
    }
  }

  Future<void> _loadFriendsDetails({
    required String currentUserId,
    required List<FriendshipModel> friendshipList,
  }) async {
    _isLoading.value = true;
    try {
      List<UserModel> friends = [];
      final futures = friendshipList.map((friendship) async {
        String friendId = friendship.getOtherUserId(currentUserId);
        return await _firestoreService.getUser(userId: friendId);
      }).toList();

      final results = await Future.wait(futures);

      for (var friend in results) {
        friends.add(friend!);
      }

      _allFriends.value = friends;
    } catch (e) {
      throw Exception("Exception during load friends details ${e.toString()}");
    }
  }

  // Load all friend requests ( Sent and received )
  void _loadAllFriendRequests() async {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _receivedFriendRequests.bindStream(
        _firestoreService.getFriendRequestsStream(userId: currentUserId),
      );

      _sentFriendRequests.bindStream(
        _firestoreService.getSentFriendRequestStream(userId: currentUserId),
      );

      _sentFriendRequests.listen((_) {
        _filterSentRequests();
      });
    }
  }

  // Filter user by name
  void _filterFriends() {
    final currentUserId = _authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredFriends.value = _allFriends;
    } else {
      _filteredFriends.value = _allFriends
          .where(
            (friend) =>
                friend.id != currentUserId &&
                friend.fullName.toLowerCase().contains(query),
          )
          .toList();
    }
  }

  // Update search query and update data list
  void updateSearchQuery({
    required String query,
    required RequestTab requestTab,
  }) {
    _searchQuery.value = query;

    if(requestTab == RequestTab.receivedRequests){
      _filterReceivedRequests();
    }

    if (requestTab == RequestTab.sendRequests) {
      _filterSentRequests();
    }

    _filterFriends();
  }

  // Clear search
  void clearSearch() {
    searchTextController.clear();
    _searchQuery.value = '';

    _filterSentRequests();
    _filterReceivedRequests();
  }

  // Filter sent requests by name
  void _filterSentRequests() {
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredSentFriendRequests.assignAll(_sentFriendRequests);
      return;
    }

    _filteredSentFriendRequests.assignAll(
      _sentFriendRequests.where((request) {
        final user = _users[request.receiverId];
        if (user == null) return false;

        return user.fullName.toLowerCase().contains(query);
      }).toList(),
    );
  }

  // Filter received requests by name
  void _filterReceivedRequests() {
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredReceivedFriendRequests.assignAll(_receivedFriendRequests);
      return;
    }

    _filteredReceivedFriendRequests.assignAll(
      _receivedFriendRequests.where((request) {
        final user = _users[request.receiverId];
        if (user == null) return false;

        return user.fullName.toLowerCase().contains(query);
      }).toList(),
    );
  }

  Future<void> removeFriend({required UserModel friend}) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    _isLoading.value = true;
    try {
      await _firestoreService.removeFriendShip(
        user1Id: currentUserId,
        user2Id: friend.id,
      );

      // Update local state immediately, don't wait for the stream
      _allFriends.removeWhere((friend) => friend.id == friend.id);
      _friendShips.removeWhere(
        (friendship) => friendship.getOtherUserId(currentUserId) == friend.id,
      );
      _filterFriends();
    } catch (e) {
      throw Exception("Exception during remove friend ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> blockFriend({required UserModel friend}) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    _isLoading.value = true;
    try {
      await _firestoreService.blockUser(
        blockerId: currentUserId,
        blockedId: friend.id,
      );

      // Update local state immediately, don't wait for the stream
      _allFriends.removeWhere((f) => f.id == friend.id);
      _friendShips.removeWhere(
        (friendship) => friendship.getOtherUserId(currentUserId) == friend.id,
      );
      _filterFriends();
    } catch (e) {
      throw Exception("Exception during block friend ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unblockFriend({required UserModel friend}) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    _isLoading.value = true;
    try {
      await _firestoreService.unBlockUser(
        unBlockerId: currentUserId,
        unBlockedId: friend.id,
      );

      // Re-fetch since the stream filters blocked friendships out entirely,
      // so this friend won't reappear on its own
      _loadAllFriends();
    } catch (e) {
      throw Exception("Exception during unblock friend ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat({required UserModel friend}) async {
    try {
      final currentUserId = _authController.user?.uid;

      Get.toNamed(
        AppRoutes.chat,
        arguments: {'chatId': null, 'otherUser': friend, 'isNewChat': true},
      );
    } catch (e) {
      throw Exception("Exception during start chat ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  String getLastSeenText({required UserModel user}) {
    if (user.isOnline) {
      return 'Online';
    } else {
      final now = DateTime.now();
      final difference = now.difference(user.lastSeen);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return 'Last seen ${difference.inMinutes} m ago';
      } else if (difference.inDays < 1) {
        return 'Last seen ${difference.inHours} h ago';
      } else if (difference.inDays < 7) {
        return 'Last seen ${difference.inDays} d ago';
      } else {
        return 'Last seen ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
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

  UserModel getUser({required String userId}) {
    return _users[userId]!;
  }

  Future<void> acceptFriendRequest({
    required FriendRequestModel request,
  }) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    _isLoading.value = true;
    try {
      await _firestoreService.respondToFriendRequest(
        requestId: request.id,
        status: FriendRequestStatus.accepted,
      );
    } catch (e) {
      throw Exception("Exception during accept friend request ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> removeFriendRequest({
    required FriendRequestModel request,
  }) async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;

    _isLoading.value = true;
    try {
      await _firestoreService.respondToFriendRequest(
        requestId: request.id,
        status: FriendRequestStatus.decline,
      );
    } catch (e) {
      throw Exception("Exception during remove friend request ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  String getRequestTimeText({required DateTime createdAt}) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
