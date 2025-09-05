// lib/core/shared/services/admin_validation_service.dart
import '../config/admin_config.dart';

class AdminValidationService {
  /// Check if a phone number is authorized to register/login as admin
  static bool isAuthorizedAdmin(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    // Normalize the phone number to different formats for comparison
    final normalizedPhone = _normalizePhoneNumber(phoneNumber);

    return AdminConfig.authorizedAdminNumbers.any((adminNumber) {
      final normalizedAdminNumber = _normalizePhoneNumber(adminNumber);
      return normalizedPhone == normalizedAdminNumber;
    });
  }

  /// Check if a phone number is the super admin
  static bool isSuperAdmin(String phoneNumber) {
    return AdminConfig.isSuperAdmin(phoneNumber);
  }

  /// Add a new admin phone number to the authorized list
  /// This method could be expanded to use a database or remote config in the future
  static void addAuthorizedAdmin(String phoneNumber) {
    // In a real app, this would save to database/backend
    // For now, this is a placeholder method
    print('Admin phone number would be added: $phoneNumber');
  }

  /// Remove an admin phone number from the authorized list
  static void removeAuthorizedAdmin(String phoneNumber) {
    // In a real app, this would remove from database/backend
    // For now, this is a placeholder method
    print('Admin phone number would be removed: $phoneNumber');
  }

  /// Get all authorized admin numbers (for admin management purposes)
  static List<String> getAuthorizedAdmins() {
    return List.unmodifiable(AdminConfig.authorizedAdminNumbers);
  }

  /// Normalize phone number for consistent comparison
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

  /// Get a user-friendly list of authorized admin numbers (masked for security)
  static List<String> getMaskedAuthorizedAdmins() {
    return AdminConfig.authorizedAdminNumbers.map((number) {
      if (number.length >= 8) {
        // Show first 4 and last 2 digits, mask the middle
        final start = number.substring(0, 4);
        final end = number.substring(number.length - 2);
        final masked = '*' * (number.length - 6);
        return '$start$masked$end';
      }
      return number;
    }).toList();
  }
}
