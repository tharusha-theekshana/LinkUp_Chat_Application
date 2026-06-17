class UserModel {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String mobile;
  final String photoUrl;
  final String bio;
  final String dob;
  final bool isOnline;
  final bool isPremiumUser;
  final DateTime lastSeen;
  final DateTime createdAt;

  final String role;
  final String status;
  final String? bannedReason;
  final DateTime? bannedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.mobile,
    required this.bio,
    required this.dob,
    this.photoUrl = "",
    this.isOnline = false,
    this.isPremiumUser = false,
    required this.lastSeen,
    required this.createdAt,
    required this.role,
    this.status = "active",
    this.bannedReason,
    this.bannedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      bio: map['bio'] ?? '',
      dob: map['dob'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      isOnline: map['isOnline'] ?? false,
      isPremiumUser: map['isPremiumUser'] ?? false,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(map['lastSeen'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      role: map['role'] ?? 'user',
      status: map['status'] ?? 'active',
      bannedReason: map['bannedReason'],
      bannedAt: map['bannedAt'] != null
          ? DateTime.parse(map['bannedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'userName': userName,
      'email': email,
      'mobile': mobile,
      'bio': bio,
      'dob': dob,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'isPremiumUser': isPremiumUser,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'role': role,
      'status': status,
      'bannedReason': bannedReason,
      'bannedAt': bannedAt?.toIso8601String(),
    };
  }
}
