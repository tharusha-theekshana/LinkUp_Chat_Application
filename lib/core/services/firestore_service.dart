import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:link_up/core/data/models/chat_model.dart';
import 'package:link_up/core/data/models/friend_request_model.dart';
import 'package:link_up/core/data/models/friendship_model.dart';
import 'package:link_up/core/data/models/message_model.dart';
import 'package:link_up/core/data/models/notification_model.dart';
import 'package:link_up/core/enums/friend_request_status.dart';
import 'package:link_up/core/enums/notification_type.dart';
import 'package:link_up/features/auth/core/data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'linkup-database',
  );

  final String _userCollection = 'users';
  final String _friendRequestCollection = 'friend_requests';
  final String _friendShips = 'friendships';
  final String _chats = 'chats';
  final String _messages = 'messages';
  final String _notifications = 'notifications';

  // Check if email already exists in Firestore
  Future<bool> isEmailAlreadyExists({required String email}) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(_userCollection)
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      return query.docs.isNotEmpty;

    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  // Create user
  Future<void> createUser({required UserModel user}) async {
    try {
      await _firestore
          .collection(_userCollection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      throw Exception("Exception during create user ${e.toString()}");
    }
  }

  // Get user data
  Future<UserModel?> getUser({required String userId}) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_userCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Exception during get user details ${e.toString()}");
    }
  }

  // Update user online status
  Future<void> updateUserOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_userCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        await _firestore.collection(_userCollection).doc(userId).update({
          'isOnline': isOnline,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw Exception(
        "Exception during update user online status ${e.toString()}",
      );
    }
  }

  // Get user data
  Future<void> deleteUser({required String userId}) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_userCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        await _firestore.collection(_userCollection).doc(userId).delete();
      }
    } catch (e) {
      throw Exception("Exception during get user details ${e.toString()}");
    }
  }

  // Get user data as stream
  Stream<UserModel?> getUserStream({required String userId}) {
    return _firestore
        .collection(_userCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_userCollection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw Exception("Exception during update user ${e.toString()}");
    }
  }

  // Get all users as stream
  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore
        .collection(_userCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Send friend request
  Future<void> sendFriendRequest({required FriendRequestModel request}) async {
    try {
      await _firestore
          .collection(_friendRequestCollection)
          .doc(request.id)
          .set(request.toMap());

      String notificationId =
          'friend request ${request.senderId} ${request.receiverId} ${DateTime.now().millisecondsSinceEpoch}';

      await createNotification(
        NotificationModel(
          id: notificationId,
          userId: request.receiverId,
          title: "Friend Request sent",
          body: "Friend request sent ${request.senderId} to ${request.receiverId}",
          type: NotificationType.friendRequest,
          data: {'senderId': request.senderId, 'requestId': request.id},
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception("Exception during send friend request ${e.toString()}");
    }
  }

  // Cancel friend request
  Future<void> cancelFriendRequest({required String requestId}) async {
    try {
      DocumentSnapshot requestDoc = await _firestore
          .collection(_friendRequestCollection)
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String, dynamic>,
        );

        await _firestore
            .collection(_friendRequestCollection)
            .doc(requestId)
            .delete();

        await deleteNotificationsByTypeAndUser(
          userId: request.receiverId,
          type: NotificationType.friendRequest,
          relatedUserId: request.senderId,
        );
      }
    } catch (e) {
      throw Exception("Exception during cancel friend request ${e.toString()}");
    }
  }

  Future<void> respondToFriendRequest({
    required String requestId,
    required FriendRequestStatus status,
  }) async {
    try {
      await _firestore
          .collection(_friendRequestCollection)
          .doc(requestId)
          .update({
            'status': status.name,
            'respondedAt': DateTime.now().millisecondsSinceEpoch,
          });

      DocumentSnapshot requestDoc = await _firestore
          .collection(_friendRequestCollection)
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromMap(
          requestDoc.data() as Map<String, dynamic>,
        );

        if (request.status == FriendRequestStatus.accepted) {
          await createFriendShip(
            user1Id: request.senderId,
            user2Id: request.receiverId,
          );

          String notificationId =
              'friend request accepted ${request.senderId} ${request.receiverId} ${DateTime.now().millisecondsSinceEpoch}';

          await createNotification(
            NotificationModel(
              id: notificationId,
              userId: request.receiverId,
              title: "Hui",
              body: "Hai",
              type: NotificationType.friendRequestAccepted,
              data: {'userId': request.receiverId},
              createdAt: DateTime.now(),
            ),
          );

          await _removeNotificationFromCancelRequest(
            receiverId: request.receiverId,
            senderId: request.senderId,
          );
        } else if (status == FriendRequestStatus.decline) {
          await createNotification(
            NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: request.senderId,
              title: "Hui",
              body: "Hai",
              type: NotificationType.friendRequestDeclined,
              data: {'userId': request.receiverId},
              createdAt: DateTime.now(),
            ),
          );

          await _removeNotificationFromCancelRequest(
            receiverId: request.receiverId,
            senderId: request.senderId,
          );
        }
      }
    } catch (e) {
      throw Exception(
        "Exception during respond to friend request ${e.toString()}",
      );
    }
  }

  Stream<List<FriendRequestModel>> getFriendRequestsStream({required String userId}) {
    return _firestore
        .collection(_friendRequestCollection)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: FriendRequestStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshots) => snapshots.docs
              .map((e) => FriendRequestModel.fromMap(e.data()))
              .toList(),
        );
  }

  Stream<List<FriendRequestModel>> getSentFriendRequestStream({
    required String userId,
  }) {
    return _firestore
        .collection(_friendRequestCollection)
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshots) => snapshots.docs
              .map((e) => FriendRequestModel.fromMap(e.data()))
              .toList(),
        );
  }

  Future<FriendRequestModel?> getFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(_friendRequestCollection)
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: FriendRequestStatus.pending.name)
          .get();

      if (query.docs.isNotEmpty) {
        return FriendRequestModel.fromMap(
          query.docs.first.data() as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      throw Exception("Exception during get friend request ${e.toString()}");
    }
  }

  Future<void> createFriendShip({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      FriendshipModel friendship = FriendshipModel(
        id: friendShipId,
        user1Id: userIds[0],
        user2Id: userIds[1],
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_friendShips)
          .doc(friendShipId)
          .set(friendship.toMap());
    } catch (e) {
      throw Exception("Exception during create friendship ${e.toString()}");
    }
  }

  // Remove friendship
  Future<void> removeFriendShip({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      await _firestore.collection(_friendShips).doc(friendShipId).delete();

      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user2Id,
        title: "Friend removed",
        body: "$user1Id removed you as a friend",
        type: NotificationType.friendRemoved,
        data: {'userId': user1Id},
        createdAt: DateTime.now(),
      );

    } catch (e) {
      throw Exception("Exception during remove friendship ${e.toString()}");
    }
  }

  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    try {
      List<String> userIds = [blockerId, blockedId];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      await _firestore.collection(_friendShips).doc(friendShipId).update({
        'isBlocked': true,
        'blockedBy': blockerId,
      });
    } catch (e) {
      throw Exception("Exception during block user ${e.toString()}");
    }
  }

  Future<void> unBlockUser({
    required String unBlockerId,
    required String unBlockedId,
  }) async {
    try {
      List<String> userIds = [unBlockerId, unBlockedId];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      await _firestore.collection(_friendShips).doc(friendShipId).update({
        'isBlocked': false,
        'blockedBy': null,
      });
    } catch (e) {
      throw Exception("Exception during un block user ${e.toString()}");
    }
  }

  Stream<List<FriendshipModel>> getFriendsStream({required String userId}) {
    return _firestore
        .collection(_friendShips)
        .where('user1Id', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot1) async {
          QuerySnapshot snapshot2 = await _firestore
              .collection(_friendShips)
              .where('user2Id', isEqualTo: userId)
              .get();

          List<FriendshipModel> friendShips = [];

          for (var doc in snapshot1.docs) {
            friendShips.add(FriendshipModel.fromMap(doc.data()));
          }

          for (var doc in snapshot2.docs) {
            friendShips.add(
              FriendshipModel.fromMap(doc.data() as Map<String, dynamic>),
            );
          }

          return friendShips.where((fShip) => !fShip.isBlocked).toList();
        });
  }

  Future<FriendshipModel?> getFriendShips({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _firestore
          .collection(_friendShips)
          .doc(friendShipId)
          .get();

      if (doc.exists) {
        return FriendshipModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw Exception("Exception during get friendships ${e.toString()}");
    }
  }

  Future<bool> isUserBlocked({
    required String userId,
    required String otherUserId,
  }) async {
    try {
      List<String> userIds = [userId, otherUserId];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _firestore
          .collection(_friendShips)
          .doc(friendShipId)
          .get();

      if (doc.exists) {
        FriendshipModel friendShip = FriendshipModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );
        return friendShip.isBlocked;
      }
      return false;
    } catch (e) {
      throw Exception("Exception during check is user blocked ${e.toString()}");
    }
  }

  Future<bool> isUnfriended({
    required String userId,
    required String otherUserId,
  }) async {
    try {
      List<String> userIds = [userId, otherUserId];
      userIds.sort();

      String friendShipId = '${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await _firestore
          .collection(_friendShips)
          .doc(friendShipId)
          .get();

      if (!doc.exists || (doc.exists && doc.data() == null)) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception("Exception during check is unfriended ${e.toString()}");
    }
  }

  Future<String> createOrGetChat({
    required String userId1,
    required String userId2,
  }) async {
    try {
      List<String> participants = [userId1, userId2];
      participants.sort();

      String chatId = '${participants[0]}_${participants[1]}';
      DocumentReference chatRef = _firestore.collection(_chats).doc(chatId);
      DocumentSnapshot chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        ChatModel newChat = ChatModel(
          id: chatId,
          participants: participants,
          unreadCount: {userId1: 0, userId2: 0},
          deletedBy: {userId1: false, userId2: false},
          lastSeenBy: {userId1: DateTime.now(), userId2: DateTime.now()},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await chatRef.set(newChat.toMap());
      } else {
        ChatModel existChat = ChatModel.fromMap(
          chatDoc.data() as Map<String, dynamic>,
        );

        if (existChat.isDeletedBy(userId1)) {
          await restoreChatForUser(chatId: chatId, userId: userId1);
        }

        if (existChat.isDeletedBy(userId2)) {
          await restoreChatForUser(chatId: chatId, userId: userId2);
        }
      }
      return chatId;
    } catch (e) {
      throw Exception("Exception during create or get chat ${e.toString()}");
    }
  }

  Stream<List<ChatModel>> getUserChatStream({required String userId}) {
    return _firestore
        .collection(_chats)
        .where('participants', arrayContains: userId)
        .orderBy('updateAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => ChatModel.fromMap(e.data()))
              .where((chat) => !chat.isDeletedBy(userId))
              .toList(),
        );
  }

  Future<void> updateChatLastMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    try {
      await _firestore.collection(_chats).doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timeStamp.millisecondsSinceEpoch,
        'lastMessageSenderId': message.senderId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception(
        "Exception during update chat last message ${e.toString()}",
      );
    }
  }

  Future<void> updateUserLastSeen({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_chats).doc(chatId).update({
        'lastSeenBy.$userId': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception("Exception during update user last seen ${e.toString()}");
    }
  }

  Future<void> deleteChatForUser({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_chats).doc(chatId).update({
        'deletedBy.$userId': true,
        'deletedAt.$userId': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception("Exception during delete chat for user ${e.toString()}");
    }
  }

  Future<void> restoreChatForUser({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_chats).doc(chatId).update({
        'deletedBy.$userId': false,
      });
    } catch (e) {
      throw Exception("Exception during restore chat : ${e.toString()}");
    }
  }

  Future<void> updateUnreadCount({
    required String chatId,
    required String userId,
    required int count,
  }) async {
    try {
      await _firestore.collection(_chats).doc(chatId).update({
        'unreadCount.$userId': count,
      });
    } catch (e) {
      throw Exception("Exception during update unread count : ${e.toString()}");
    }
  }

  Future<void> restoreUnreadCount({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_chats).doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      throw Exception(
        "Exception during restore unread count : ${e.toString()}",
      );
    }
  }

  // Message section
  Future<void> sendMessage({required MessageModel message}) async {
    try {
      await _firestore
          .collection(_messages)
          .doc(message.id)
          .set(message.toMap());

      String chatId = await createOrGetChat(
        userId1: message.senderId,
        userId2: message.receiverId,
      );

      await updateChatLastMessage(chatId: chatId, message: message);
      await updateUserLastSeen(chatId: chatId, userId: message.senderId);

      DocumentSnapshot chatDoc = await _firestore
          .collection(_chats)
          .doc(chatId)
          .get();

      if (chatDoc.exists) {
        ChatModel chat = ChatModel.fromMap(
          chatDoc.data() as Map<String, dynamic>,
        );

        int currentUnRead = chat.getUnreadCount(message.receiverId);

        await updateUnreadCount(
          chatId: chatId,
          userId: message.receiverId,
          count: currentUnRead + 11,
        );
      }
    } catch (e) {
      throw Exception("Exception during send message : ${e.toString()}");
    }
  }

  Stream<List<MessageModel>> getMessageStream({
    required String userId1,
    required String userId2,
  }) {
    return _firestore
        .collection(_messages)
        .where('senderId', whereIn: [userId1, userId2])
        .snapshots()
        .asyncMap((snapshots) async {
          List<String> participants = [userId1, userId2];
          participants.sort();

          String chatId = '${participants[0]}_${participants[1]}';

          DocumentSnapshot chatDoc = await _firestore
              .collection(_chats)
              .doc(chatId)
              .get();

          ChatModel? chat;
          if (chatDoc.exists) {
            chat = ChatModel.fromMap(chatDoc.data() as Map<String, dynamic>);
          }

          List<MessageModel> messages = [];
          for (var doc in snapshots.docs) {
            MessageModel message = MessageModel.fromMap(doc.data());

            if ((message.senderId == userId1 &&
                    message.receiverId == userId2) ||
                (message.senderId == userId2 &&
                    message.receiverId == userId1)) {
              bool includeMessage = true;

              if (chat != null) {
                DateTime? currentUserDeletedAt = chat.getDeletedAt(userId1);

                if (currentUserDeletedAt != null &&
                    message.timeStamp.isBefore(currentUserDeletedAt)) {
                  includeMessage = false;
                }
              }

              if (includeMessage) {
                messages.add(message);
              }
            }
          }

          messages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
          return messages;
        });
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection(_messages).doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception(
        "Exception during mark message as read : ${e.toString()}",
      );
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _firestore.collection(_messages).doc(messageId).delete();
    } catch (e) {
      throw Exception("Exception during delete message : ${e.toString()}");
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      await _firestore.collection(_messages).doc(messageId).update({
        'content': newContent,
        'isEdit': true,
        'editedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception("Exception during edit message : ${e.toString()}");
    }
  }

  // Notification section
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(_notifications)
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      throw Exception("Exception during create notification : ${e.toString()}");
    }
  }

  Stream<List<NotificationModel>> getNotificationStream({
    required String userId,
  }) {
    return _firestore
        .collection(_notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => NotificationModel.fromMap(e.data()))
              .toList(),
        );
  }

  Future<void> markAsRead({required String notificationId}) async {
    try {
      await _firestore.collection(_notifications).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception(
        "Exception during notification mark as read : ${e.toString()}",
      );
    }
  }

  Future<void> markAllNotificationsAsRead({required String userId}) async {
    try {
      QuerySnapshot notifications = await _firestore
          .collection(_notifications)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
    } catch (e) {
      throw Exception(
        "Exception during all notifications mark as read : ${e.toString()}",
      );
    }
  }

  Future<void> deleteNotification({required String notificationId}) async {
    try {
      await _firestore.collection(_notifications).doc(notificationId).delete();
    } catch (e) {
      throw Exception("Exception during delete notification : ${e.toString()}");
    }
  }

  // Delete notification friend request
  Future<void> deleteNotificationsByTypeAndUser({
    required String userId,
    required NotificationType type,
    required String relatedUserId,
  }) async {
    try {
      QuerySnapshot notifications = await _firestore
          .collection(_notifications)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in notifications.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['data'] != null &&
            (data['data']['senderId'] == relatedUserId ||
                data['data']['userId'] == relatedUserId)) {
          batch.delete(doc.reference);
        }
      }
    } catch (e) {
      throw Exception("Exception during delete notification : ${e.toString()}");
    }
  }

  Future<void> _removeNotificationFromCancelRequest({
    required String receiverId,
    required String senderId,
  }) async {
    try {
      await deleteNotificationsByTypeAndUser(
        userId: receiverId,
        type: NotificationType.friendRequest,
        relatedUserId: senderId,
      );
    } catch (e) {
      throw Exception(
        "Exception during remove notification from cancel request : ${e.toString()}",
      );
    }
  }
}
