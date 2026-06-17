import 'dart:io';

class UserDataEntity {
  final String fullName;
  final String userName;
  final String email;
  final String password;
  final String mobile;
  final File profilePic;
  final String bio;
  final String dob;

  UserDataEntity({
    required this.fullName,
    required this.userName,
    required this.email,
    required this.password,
    required this.mobile,
    required this.profilePic,
    required this.bio,
    required this.dob,
  });
}
