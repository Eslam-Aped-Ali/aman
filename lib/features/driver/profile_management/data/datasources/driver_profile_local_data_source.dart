import '../models/driver_profile_model.dart';
import '../../domain/entities/driver_profile.dart';

abstract class DriverProfileLocalDataSource {
  Future<DriverProfileModel?> getDriverProfile(String driverId);
  Future<DriverProfileModel> updateDriverProfile(DriverProfileModel profile);
  Future<DriverProfileModel> createDriverProfile({
    required String name,
    required String phoneNumber,
    required Gender gender,
    required int birthYear,
  });
  Future<void> contactAdmin(String phoneNumber);
}

class DriverProfileLocalDataSourceImpl implements DriverProfileLocalDataSource {
  // Dummy data - replace with actual local storage later
  static final Map<String, DriverProfileModel> _dummyDrivers = {};

  @override
  Future<DriverProfileModel?> getDriverProfile(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyDrivers[driverId];
  }

  @override
  Future<DriverProfileModel> updateDriverProfile(
      DriverProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyDrivers[profile.id] = profile;
    return profile;
  }

  @override
  Future<DriverProfileModel> createDriverProfile({
    required String name,
    required String phoneNumber,
    required Gender gender,
    required int birthYear,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final profile = DriverProfileModel(
      id: 'driver_$phoneNumber',
      name: name,
      phoneNumber: phoneNumber,
      gender: gender,
      birthYear: birthYear,
      status: DriverStatus.pending, // Always pending initially
      createdAt: DateTime.now(),
    );

    _dummyDrivers[profile.id] = profile;
    return profile;
  }

  @override
  Future<void> contactAdmin(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate contacting admin - could integrate with messaging service
    print('Contacted admin from phone number: $phoneNumber');
  }

  // Helper method to simulate admin approval (for testing)
  static Future<void> approveDriver(String driverId) async {
    final driver = _dummyDrivers[driverId];
    if (driver != null) {
      _dummyDrivers[driverId] = driver.copyWith(
        status: DriverStatus.approved,
        approvedAt: DateTime.now(),
      );
    }
  }

  // Helper method to get all drivers (for admin panel later)
  static Map<String, DriverProfileModel> getAllDrivers() {
    return Map.from(_dummyDrivers);
  }
}
