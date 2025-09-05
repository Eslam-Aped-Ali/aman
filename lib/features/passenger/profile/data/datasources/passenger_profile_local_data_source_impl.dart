import '../models/passenger_profile_model.dart';
import 'passenger_profile_data_source.dart';

class PassengerProfileLocalDataSourceImpl
    implements PassengerProfileLocalDataSource {
  @override
  Future<PassengerProfileModel?> getCachedProfile(String userId) async {
    // For now, return null - no caching implemented
    return null;
  }

  @override
  Future<void> cacheProfile(PassengerProfileModel profile) async {
    // For now, do nothing - no caching implemented
  }

  @override
  Future<void> clearCache(String userId) async {
    // For now, do nothing - no caching implemented
  }
}
