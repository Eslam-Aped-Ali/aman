import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../../../../../core/shared/usecases/usecase_abstract.dart';
import '../entities/passenger_profile.dart';
import '../repositories/passenger_profile_repository.dart';

class GetPassengerProfileUseCase implements UseCase<PassengerProfile, String> {
  final PassengerProfileRepository repository;

  GetPassengerProfileUseCase(this.repository);

  @override
  Future<Either<Failure, PassengerProfile>> call(String userId) async {
    return await repository.getProfile(userId);
  }
}

class UpdatePassengerProfileParams {
  final String userId;
  final Map<String, dynamic> profileData;

  UpdatePassengerProfileParams({
    required this.userId,
    required this.profileData,
  });
}

class UpdatePassengerProfileUseCase
    implements UseCase<PassengerProfile, UpdatePassengerProfileParams> {
  final PassengerProfileRepository repository;

  UpdatePassengerProfileUseCase(this.repository);

  @override
  Future<Either<Failure, PassengerProfile>> call(
      UpdatePassengerProfileParams params) async {
    return await repository.updateProfile(params.userId, params.profileData);
  }
}

class UpdatePreferencesParams {
  final String userId;
  final Map<String, bool> preferences;

  UpdatePreferencesParams({
    required this.userId,
    required this.preferences,
  });
}

class UpdatePassengerPreferencesUseCase
    implements UseCase<bool, UpdatePreferencesParams> {
  final PassengerProfileRepository repository;

  UpdatePassengerPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdatePreferencesParams params) async {
    return await repository.updatePreferences(
        params.userId, params.preferences);
  }
}
