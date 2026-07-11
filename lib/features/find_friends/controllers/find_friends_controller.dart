import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/utils/app_messages.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/snack_bar/app_snack_bar.dart';
import '../../../routes/app_routes.dart';
import '../../../core/enums/friend_request_status.dart';
import '../../../core/enums/user_relationship_status.dart';
import '../../../core/data/models/friend_request_model.dart';
import '../../../core/data/models/friendship_model.dart';
import '../../auth/core/data/models/user_model.dart';
import '../../auth/core/controllers/auth_controller.dart';
import '../../../core/services/firestore_service.dart';

class FindFriendsController extends GetxController {
  final _firestoreService = Get.find<FirestoreService>();
  final _authController = Get.find<AuthController>();
  final Uuid _uuid = Uuid();

  // Form controller
  final searchTextController = TextEditingController();

  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<String> _searchQuery = Rx<String>("");

  // For users
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
    _loadAllUsers();
    _loadRelationShips();

    // Wait short time for update filter users
    debounce(
      _sentRequests,
      (_) => _filterUsers(),
      time: Duration(microseconds: 300),
    );
  }

  // Update search query
  void updateSearchQuery({required String query}) {
    _searchQuery.value = query;
    _filterUsers();
  }

  // Clear search query
  void clearSearch() {
    searchTextController.clear();
    _searchQuery.value = '';

    _filterUsers();
  }

  // Load all users
  void _loadAllUsers() {
    _users.bindStream(_firestoreService.getAllUsersStream());

    ever<List<UserModel>>(_users, (userList) {
      _filterUsers();
    });
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

  // Update relationship status
  void _updateAllRelationshipStatus() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId == null) {
      return;
    }

    for (var user in _users) {
      if (user.id != currentUserId) {
        final status = _calculateRelationshipStatus(userId: user.id);
        _userRelationShips[user.id] = status;
      }
    }
  }

  // Check relationship status
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
      AppSnackBar.error(
        title: AppMessages.actionFailed,
        message: "The friend request could not be sent at this time. Please try again later.",
        context: Get.context!,
      );
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
      AppSnackBar.error(
        title: AppMessages.actionFailed,
        message: "The friend request could not be cancel at this time. Please try again later.",
        context: Get.context!,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Accept friend request
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
      AppSnackBar.error(
        title: AppMessages.actionFailed,
        message: "The friend request could not be accept at this time. Please try again later.",
        context: Get.context!,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Decline friend request
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
      AppSnackBar.error(
        title: AppMessages.actionFailed,
        message: "The friend request could not be decline at this time. Please try again later.",
        context: Get.context!,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Start chat
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

        Get.toNamed(
          AppRoutes.changePassword,
          arguments: {'chatId': chatId, 'otherUser': user},
        );
            }
    } catch (e) {
      AppSnackBar.error(
        title: AppMessages.actionFailed,
        message: "Something went wrong while opening the chat. Please try again later.",
        context: Get.context!,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Get status of relationship
  UserRelationshipStatus getUserRelationshipStatus({required String userId}) {
    return _userRelationShips[userId] ?? UserRelationshipStatus.none;
  }

  // Calculate last seen
  String getLastSeenText({required UserModel user}) {
    if (user.isOnline) {
      return 'Online';
    } else {
      final now = DateTime.now();
      final difference = now.difference(user.lastSeen);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return 'Last seen ${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return 'Last seen ${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return 'Last seen ${difference.inDays}d ago';
      } else {
        return 'Last seen ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
  }
}
