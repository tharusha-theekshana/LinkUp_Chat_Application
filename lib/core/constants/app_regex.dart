class AppRegex {
  static final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$');
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp fullNameRegex = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp mobileNumberRegex = RegExp(r'^0(7[0-9]{8})$');
}
