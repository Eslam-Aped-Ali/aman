import '../models/passenger_profile_model.dart';

abstract class PassengerProfileRemoteDataSource {
  Future<PassengerProfileModel> getProfile(String userId);
  Future<PassengerProfileModel> updateProfile(
      String userId, Map<String, dynamic> profileData);
  Future<bool> updatePreferences(String userId, Map<String, bool> preferences);
  Future<String?> uploadProfileImage(String userId, String imagePath);
  Future<bool> deleteProfile(String userId);
}

abstract class PassengerProfileLocalDataSource {
  Future<PassengerProfileModel?> getCachedProfile(String userId);
  Future<void> cacheProfile(PassengerProfileModel profile);
  Future<void> clearCache(String userId);
}
