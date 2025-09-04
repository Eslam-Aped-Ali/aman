import '../../domain/entities/driver_profile.dart';
import '../../domain/repositories/driver_profile_repository.dart';
import '../datasources/driver_profile_local_data_source.dart';
import '../models/driver_profile_model.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  final DriverProfileLocalDataSource localDataSource;

  DriverProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<DriverProfile?> getDriverProfile(String driverId) async {
    return await localDataSource.getDriverProfile(driverId);
  }

  @override
  Future<DriverProfile> updateDriverProfile(DriverProfile profile) async {
    return await localDataSource.updateDriverProfile(
      profile as DriverProfileModel,
    );
  }

  @override
  Future<DriverProfile> createDriverProfile({
    required String name,
    required String phoneNumber,
    required Gender gender,
    required int birthYear,
  }) async {
    return await localDataSource.createDriverProfile(
      name: name,
      phoneNumber: phoneNumber,
      gender: gender,
      birthYear: birthYear,
    );
  }

  @override
  Future<void> contactAdmin(String phoneNumber) async {
    return await localDataSource.contactAdmin(phoneNumber);
  }
}
