import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../exceptions/app_exception.dart';
import '../exceptions/firebase_exceptions.dart';
import '../utils/app_messages.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String _profilePictures = 'profile_pictures';

  // Uploads a profile picture and returns the download URL
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child(_profilePictures).child('$userId.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }

  // Deletes a profile picture from storage
  Future<void> deleteProfilePicture({required String userId}) async {
    try {
      final ref = _storage.ref().child(_profilePictures).child('$userId.jpg');
      await ref.delete();
    } on FirebaseAuthException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } on FirebaseException catch (e) {
      throw AppException(message: FirebaseExceptions.getMessage(e.code));
    } catch (e) {
      throw AppException(message: AppMessages.exceptionMessage);
    }
  }
}
