import 'package:get/get.dart';
import 'package:link_up/core/enums/notification_type.dart';

import '../../features/auth/core/controllers/auth_controller.dart';
import '../../features/auth/core/data/models/user_model.dart';
import '../data/models/notification_model.dart';
import '../services/firestore_service.dart';

class NotificationController extends GetxController {
  final _firestoreService = Get.find<FirestoreService>();
  final _authController = Get.find<AuthController>();

  final Rx<bool> _isLoading = Rx<bool>(false);
  final RxMap<String, UserModel> _users = RxMap<String, UserModel>({});

  final RxList<NotificationModel> _notifications = RxList<NotificationModel>(
    [],
  );

  Rx<bool> get isLoading => _isLoading;

  RxMap<String, UserModel> get users => _users;

  RxList<NotificationModel> get notifications => _notifications;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    _loadUsers();
  }

  void _loadNotifications() {
    final currentUserId = _authController.user?.uid;

    _notifications.bindStream(
      _firestoreService.getNotificationStream(userId: currentUserId!),
    );
  }

  int getUnreadNotificationCount() {
    return _notifications
        .where((notificationId) => notificationId.isRead)
        .length;
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

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  Future<void> markAsRead({required NotificationModel notification}) async {
    try {
      if(!notification.isRead){
        await _firestoreService.markAsRead(notificationId: notification.id);
      }
    } catch (e) {}
  }


  Future<void> markAllAsRead() async {
    try {
      final currentUserId = _authController.user!.uid;

      await _firestoreService.markAllNotificationsAsRead(userId: currentUserId);
    } catch (e) {}
  }

  Future<void> deleteNotification({required NotificationModel notification}) async {
    try {
      await _firestoreService.deleteNotification(notificationId: notification.id);
    } catch (e) {}
  }

  Future<void> handleNotificationTap({required NotificationModel notification}) async {
    try {
      await markAsRead(notification: notification);

      switch(notification.type){
        case NotificationType.friendRequest:
          Get.toNamed("");
          break;

        case NotificationType.newMessage :
          Get.toNamed("");
          break;

        case NotificationType.friendRemoved :
          break;

        case NotificationType.friendRequestAccepted:
          break;

        case NotificationType.friendRequestDeclined:
          break;
      }

    } catch (e) {}
  }

  String getNotificationTimeText({required DateTime createdAt}) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

}
