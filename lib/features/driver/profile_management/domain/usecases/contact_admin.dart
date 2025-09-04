import '../repositories/driver_profile_repository.dart';

class ContactAdminUseCase {
  final DriverProfileRepository repository;

  ContactAdminUseCase(this.repository);

  Future<void> call(String phoneNumber) async {
    return await repository.contactAdmin(phoneNumber);
  }
}
