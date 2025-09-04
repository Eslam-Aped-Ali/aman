import '../entities/driver_profile.dart';
import '../repositories/driver_profile_repository.dart';

class GetDriverProfileUseCase {
  final DriverProfileRepository repository;

  GetDriverProfileUseCase(this.repository);

  Future<DriverProfile?> call(String driverId) async {
    return await repository.getDriverProfile(driverId);
  }
}
