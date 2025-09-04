import '../entities/driver_profile.dart';

abstract class DriverProfileRepository {
  Future<DriverProfile?> getDriverProfile(String driverId);
  Future<DriverProfile> updateDriverProfile(DriverProfile profile);
  Future<DriverProfile> createDriverProfile({
    required String name,
    required String phoneNumber,
    required Gender gender,
    required int birthYear,
  });
  Future<void> contactAdmin(String phoneNumber);
}
