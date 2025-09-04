import 'package:dartz/dartz.dart';

import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/passenger_profile.dart';

abstract class PassengerProfileRepository {
  Future<Either<Failure, PassengerProfile>> getProfile(String userId);
  Future<Either<Failure, PassengerProfile>> updateProfile(
      String userId, Map<String, dynamic> profileData);
  Future<Either<Failure, bool>> updatePreferences(
      String userId, Map<String, bool> preferences);
  Future<Either<Failure, String?>> uploadProfileImage(
      String userId, String imagePath);
  Future<Either<Failure, bool>> deleteProfile(String userId);
}
