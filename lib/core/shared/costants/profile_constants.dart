class ProfileConstants {
  static const String defaultProfileImage = 'assets/icons/profile.png';

  // Gender options
  static const List<String> genderOptions = ['male', 'female', 'other'];

  // Validation patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[\d\s\-\(\)]+$';

  // Profile completion requirements
  static const List<String> requiredFields = [
    'first_name',
    'last_name',
    'phone',
  ];

  // Storage keys
  static const String keyFirstName = 'first_name';
  static const String keyLastName = 'last_name';
  static const String keyEmail = 'email';
  static const String keyPhone = 'phone_number';
  static const String keyEmergencyContact = 'emergency_contact';
  static const String keyGender = 'gender';
  static const String keyBirthDate = 'birth_date';
  static const String keyProfileImage = 'profile_image_url';
  static const String keyNotificationPref = 'preference_notifications';
  static const String keyLocationPref = 'preference_location_services';

  // UI Constants
  static const double profileImageSize = 100.0;
  static const double tabletProfileImageSize = 120.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;

  // Animation durations
  static const Duration fadeAnimationDuration = Duration(milliseconds: 800);
  static const Duration slideAnimationDuration = Duration(milliseconds: 1200);
  static const Duration loadingDelay = Duration(milliseconds: 1500);
}
