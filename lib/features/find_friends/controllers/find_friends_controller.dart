import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:link_up/core/data/models/friend_request_model.dart';
import 'package:link_up/core/data/models/friendship_model.dart';
import 'package:link_up/core/enums/friend_request_status.dart';
import 'package:link_up/core/enums/user_relationship_status.dart';
import 'package:link_up/core/services/firestore_service.dart';
import 'package:link_up/features/auth/core/controllers/auth_controller.dart';
import 'package:link_up/features/auth/core/data/models/user_model.dart';
import 'package:link_up/routes/app_routes.dart';
import 'package:uuid/uuid.dart';

class FindFriendsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final Uuid _uuid = Uuid();

  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<String> _searchQuery = Rx<String>("");

  final RxList<UserModel> _users = RxList<UserModel>([]);
  final RxList<UserModel> _filteredUsers = RxList<UserModel>([]);

  final RxMap<String, UserRelationshipStatus> _userRelationShips =
      RxMap<String, UserRelationshipStatus>();
  final RxList<FriendRequestModel> _sentRequests = RxList<FriendRequestModel>(
    [],
  );
  final RxList<FriendRequestModel> _receiveRequests =
      RxList<FriendRequestModel>([]);

  final RxList<FriendshipModel> _friendships = RxList<FriendshipModel>([]);

  // Getters
  Rx<bool> get isLoading => _isLoading;
  String get searchQuery => _searchQuery.value;
  RxList<UserModel> get users => _users;
  RxList<UserModel> get filteredUsers => _filteredUsers;
  RxMap<String, UserRelationshipStatus> get userRelationShips =>
      _userRelationShips;
  RxList<FriendRequestModel> get sentRequests => _sentRequests;
  RxList<FriendRequestModel> get receiveRequests => _receiveRequests;
  RxList<FriendshipModel> get friendships => _friendships;


  set searchQuery(String value) {
    _searchQuery.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadRelationShips();

    debounce(
      _sentRequests,
      (_) => _filterUsers(),
      time: Duration(microseconds: 300),
    );
  }

  // Load all users
  void _loadUsers() async {
    _users.bindStream(_firestoreService.getAllUsersStream());

    ever(users, List<UserModel> userList) {
      final currentUserId = _authController.user!.uid;
      final otherUsers = userList.where((user) => user.id != currentUserId).toList();

      if (searchQuery.isEmpty) {
        _filteredUsers.value = otherUsers;
      } else {
        _filterUsers();
      }
    }
  }

  // Load relationships
  void _loadRelationShips() async {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _sentRequests.bindStream(
        _firestoreService.getSentFriendRequestStream(userId: currentUserId),
      );
      _receiveRequests.bindStream(
        _firestoreService.getSentFriendRequestStream(userId: currentUserId),
      );
      _friendships.bindStream(
        _firestoreService.getFriendsStream(userId: currentUserId),
      );

      ever(_sentRequests, (_) => _updateAllRelationshipStatus());
      ever(_receiveRequests, (_) => _updateAllRelationshipStatus());
      ever(_friendships, (_) => _updateAllRelationshipStatus());

      ever(_users, (_) => _updateAllRelationshipStatus());
    }
  }

  void _updateAllRelationshipStatus() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      return;
    }

    for (var user in _users) {
      if (user.id != currentUserId) {
        final status = _calculateRelationshipStatus(userId: user.id);
        _userRelationShips[user.id] = status;
      }
    }
  }

  UserRelationshipStatus _calculateRelationshipStatus({
    required String userId,
  }) {
    final currentUserId = _authController.user?.uid;

    if (currentUserId == null) return UserRelationshipStatus.none;

    final friendship = _friendships.firstWhereOrNull(
      (f) =>
          (f.user1Id == currentUserId && f.user2Id == userId) ||
          (f.user1Id == userId && f.user2Id == currentUserId),
    );

    if (friendship != null) {
      if (friendship.isBlocked) {
        return UserRelationshipStatus.blocked;
      } else {
        return UserRelationshipStatus.friends;
      }
    }

    final senRequest = _sentRequests.firstWhereOrNull(
      (r) => r.receiverId == userId && r.status == FriendRequestStatus.pending,
    );

    if (senRequest != null) {
      return UserRelationshipStatus.friendRequestSent;
    }

    final receiveRequest = _sentRequests.firstWhereOrNull(
      (r) => r.receiverId == userId && r.status == FriendRequestStatus.pending,
    );

    if (receiveRequest != null) {
      return UserRelationshipStatus.friendRequestReceived;
    }

    return UserRelationshipStatus.none;
  }

  // Filter user by name
  void _filterUsers() {
    final currentUserId = _authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();

    if (query.isEmpty) {
      _filteredUsers.value = _users
          .where((user) => user.id != currentUserId)
          .toList();
    } else {
      _filteredUsers.value = _users
          .where(
            (user) =>
        user.id != currentUserId &&
            user.fullName.toLowerCase().contains(query),
      )
          .toList();
    }
  }

  void updateSearchQuery({required String query}) {
    _searchQuery.value = query;
    _filterUsers();
  }

  void _clearSearch() {
    _searchQuery.value = '';
  }

  // Send friend request
  Future<void> sendFriendRequest({required UserModel user}) async {
    _isLoading.value = true;
    try {
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final request = FriendRequestModel(
          id: _uuid.v4(),
          senderId: currentUserId,
          receiverId: user.id,
          status: FriendRequestStatus.pending,
          createdAt: DateTime.now(),
        );

        _userRelationShips[user.id] = UserRelationshipStatus.friendRequestSent;
        await _firestoreService.sendFriendRequest(request: request);
      }
    } catch (e) {
      _userRelationShips[user.id] = UserRelationshipStatus.friendRequestSent;
      throw Exception("Exception during send friend request ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  // Cancel friend request
  Future<void> cancelFriendRequest({required UserModel user}) async {
    _isLoading.value = true;
    try {
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final request = _sentRequests.firstWhereOrNull(
          (request) =>
              request.receiverId == user.id &&
              request.status == FriendRequestStatus.pending,
        );

        if (request != null) {
          _userRelationShips[user.id] = UserRelationshipStatus.none;
          await _firestoreService.cancelFriendRequest(requestId: request.id);
        }
      }
    } catch (e) {
      _userRelationShips[user.id] = UserRelationshipStatus.friendRequestSent;
      throw Exception("Exception during cancel friend request ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> acceptFriendRequest({required UserModel user}) async {
    _isLoading.value = true;
    try {
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final request = _sentRequests.firstWhereOrNull(
          (request) =>
              request.receiverId == user.id &&
              request.status == FriendRequestStatus.pending,
        );

        if (request != null) {
          _userRelationShips[user.id] = UserRelationshipStatus.friends;
          await _firestoreService.respondToFriendRequest(
            requestId: request.id,
            status: FriendRequestStatus.accepted,
          );
        }
      }
    } catch (e) {
      _userRelationShips[user.id] = UserRelationshipStatus.friendRequestSent;
      throw Exception("Exception during accept friend request ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> declineFriendRequest({required UserModel user}) async {
    _isLoading.value = true;
    try {
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final request = _sentRequests.firstWhereOrNull(
          (request) =>
              request.receiverId == user.id &&
              request.status == FriendRequestStatus.pending,
        );

        if (request != null) {
          _userRelationShips[user.id] = UserRelationshipStatus.none;
          await _firestoreService.respondToFriendRequest(
            requestId: request.id,
            status: FriendRequestStatus.decline,
          );
        }
      }
    } catch (e) {
      _userRelationShips[user.id] = UserRelationshipStatus.friendRequestSent;
      throw Exception(
        "Exception during decline friend request ${e.toString()}",
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat({required UserModel user}) async {
    _isLoading.value = true;
    try {
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final relationship =
            _userRelationShips[user.id] ?? UserRelationshipStatus.none;

        if (relationship != UserRelationshipStatus.friends) {
          return;
        }

        final chatId = await _firestoreService.createOrGetChat(
          userId1: currentUserId,
          userId2: user.id,
        );

        if (chatId != null) {
          Get.toNamed(
            AppRoutes.changePassword,
            arguments: {'chatId': chatId, 'otherUser': user},
          );
        }
      }
    } catch (e) {
      throw Exception("Exception during start chat ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  UserRelationshipStatus getUserRelationshipStatus({required String userId}) {
    return _userRelationShips[userId] ?? UserRelationshipStatus.none;
  }

  IconData getRelationshipButtonIcon({required UserRelationshipStatus status}) {
    switch (status) {
      case UserRelationshipStatus.none:
        return Icons.person_add;
      case UserRelationshipStatus.friendRequestSent:
        return Icons.access_time;
      case UserRelationshipStatus.friendRequestReceived:
        return Icons.check;
      case UserRelationshipStatus.friends:
        return Icons.chat_bubble_outline_outlined;
      case UserRelationshipStatus.blocked:
        return Icons.block;
    }
  }

  Color getRelationshipButtonColor({required UserRelationshipStatus status}) {
    switch (status) {
      case UserRelationshipStatus.none:
        return Colors.blue;
      case UserRelationshipStatus.friendRequestSent:
        return Colors.red;
      case UserRelationshipStatus.friendRequestReceived:
        return Colors.yellow;
      case UserRelationshipStatus.friends:
        return Colors.green;
      case UserRelationshipStatus.blocked:
        return Colors.deepOrange;
    }
  }

  void handleRelationshipButtonPress({required UserModel user}) {
    final status = getUserRelationshipStatus(userId: user.id);

    switch (status) {
      case UserRelationshipStatus.none:
        sendFriendRequest(user: user);
        break;

      case UserRelationshipStatus.friendRequestSent:
        cancelFriendRequest(user: user);
        break;

      case UserRelationshipStatus.friendRequestReceived:
        acceptFriendRequest(user: user);
        break;

      case UserRelationshipStatus.friends:
        startChat(user: user);
        break;

      case UserRelationshipStatus.blocked:
        break;
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
}
