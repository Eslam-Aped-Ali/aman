import '../entities/driver_profile.dart';
import '../repositories/driver_profile_repository.dart';

class CreateDriverProfileUseCase {
  final DriverProfileRepository repository;

  CreateDriverProfileUseCase(this.repository);

  Future<DriverProfile> call({
    required String name,
    required String phoneNumber,
    required Gender gender,
    required int birthYear,
  }) async {
    return await repository.createDriverProfile(
      name: name,
      phoneNumber: phoneNumber,
      gender: gender,
      birthYear: birthYear,
    );
  }
}
