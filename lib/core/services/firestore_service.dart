import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:link_up/features/auth/core/data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'linkup-database',
  );

  final String _userCollection = 'users';

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
}
