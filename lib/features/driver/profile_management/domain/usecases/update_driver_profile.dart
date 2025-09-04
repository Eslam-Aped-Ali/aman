import '../entities/driver_profile.dart';
import '../repositories/driver_profile_repository.dart';

class UpdateDriverProfileUseCase {
  final DriverProfileRepository repository;

  UpdateDriverProfileUseCase(this.repository);

  Future<DriverProfile> call(DriverProfile profile) async {
    return await repository.updateDriverProfile(profile);
  }
}
