class AppRoutes {

  static const String splash = '/splash';
  static const String landing = '/landing';

  // Auth routers
  static const String login = '/auth/sign-in';
  static const String signUpBasicDetails = '/auth/sign-up/basic-details-view';
  static const String signUpSetPassword = '/auth/sign-up/set-password-view';
  static const String signUpEmailVerification = '/auth/sign-up/email-verification';
  static const String signUpProfilePicDetails = '/auth/sign-up/profile-pic-view';
  static const String signUpBioDetails = '/auth/sign-up/bio-details-view';

  static const String forgotPassword = '/auth/forgot-password/initial-view';
  static const String forgotPasswordEmailSent = '/auth/forgot-password/email-sent-view';

  static const String changePassword = '/auth/change-password';

  // Chat
  static const String chat = '/chats';
  static const String individualChat = '/chats/chat-individual';

  // Find friends
  static const String friends = '/friends';

  // Find friends
  static const String findFriends = '/find-friends';

  // Profile
  static const String profile = '/profile';
}