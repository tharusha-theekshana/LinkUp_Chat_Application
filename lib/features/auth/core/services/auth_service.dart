import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/firebase_exceptions.dart';
import '../../../../core/utils/app_messages.dart';
import '../data/entities/user_data_entity.dart';
import '../data/models/user_model.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../../../core/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _firestoreService.updateUserOnlineStatus(
          userId: user.uid,
          isOnline: true,
        );
        return await _firestoreService.getUser(userId: user.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }

  // Sign in with email and password
  Future<UserModel?> registerWithEmailAndPassword({
    required UserDataEntity userData,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: userData.email,
        password: userData.password,
      );
      User? user = result.user;

      if (user != null) {
        // Update firebase auth display name
        await user.updateDisplayName(userData.fullName);

        String? photoUrl;

        // Store profile pic in firebase cloud storage and get url
        photoUrl = await _storageService.uploadProfilePicture(
          userId: user.uid,
          imageFile: userData.profilePic,
        );

        await user.updatePhotoURL(photoUrl);

        final userModel = UserModel(
          id: user.uid,
          fullName: userData.fullName,
          userName: userData.userName,
          email: userData.email,
          mobile: userData.mobile,
          bio: userData.bio,
          dob: userData.dob,
          photoUrl: photoUrl,
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
          role: "user",
        );

        // Send email verification link to user
        await user.sendEmailVerification();

        await _firestoreService.createUser(user: userModel);
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }

  // Resend email verification
  Future<void> resendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }

  // Check if email is verified (reload user first)
  Future<bool> checkEmailVerified() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await user.reload();
        return _auth.currentUser?.emailVerified ?? false;
      }

      return false;
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }

  // Forgot password send password rest email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }

  // Sign out with firebase
  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await _firestoreService.updateUserOnlineStatus(
          userId: currentUserId!,
          isOnline: false,
        );
      }
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await _firestoreService.deleteUser(userId: user.uid);
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }
}
