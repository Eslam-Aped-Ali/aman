// lib/core/shared/config/admin_config.dart
class AdminConfig {
  /// List of authorized admin phone numbers
  /// Add new admin numbers here
  static const List<String> authorizedAdminNumbers = [
    // Format: +968XXXXXXXX or local format XXXXXXXX
    '+96899887766', // Admin 1
    '+96877665544', // Admin 2
    '+96855443322', // Admin 3
    '+96833221100', // Admin 4

    // You can also add local format numbers
    '92420578', // Admin 5 (local format)
    '95123456', // Admin 6 (local format)

    // Add more admin numbers as needed...
  ];

  /// Super admin number (can manage other admins)
  static const String superAdminNumber = '+96899887766';

  /// Check if a number is the super admin
  static bool isSuperAdmin(String phoneNumber) {
    return _normalizePhoneNumber(phoneNumber) ==
        _normalizePhoneNumber(superAdminNumber);
  }

  /// Normalize phone number for comparison
  static String _normalizePhoneNumber(String phoneNumber) {
    // Remove all spaces, dashes, and other non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If it starts with +968, keep as is
    if (cleaned.startsWith('+968')) {
      return cleaned;
    }

    // If it starts with 968, add +
    if (cleaned.startsWith('968')) {
      return '+$cleaned';
    }

    // If it's 8 digits and starts with valid Oman prefixes, add +968
    if (cleaned.length == 8 && RegExp(r'^[23789]').hasMatch(cleaned)) {
      return '+968$cleaned';
    }

    // Return as is for other formats
    return cleaned;
  }
}
