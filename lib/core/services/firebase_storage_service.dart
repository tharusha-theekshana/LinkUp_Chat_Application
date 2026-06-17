import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Uploads a profile picture and returns the download URL
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }

  // Deletes a profile picture from storage
  Future<void> deleteProfilePicture({required String userId}) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete profile picture: ${e.toString()}');
    }
  }
}