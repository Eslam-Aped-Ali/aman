import 'package:dartz/dartz.dart';

import '../../../../../core/shared/error_handling/failures.dart';
import '../../../../../core/shared/error_handling/exceptions.dart';
import '../../domain/entities/passenger_profile.dart';
import '../../domain/repositories/passenger_profile_repository.dart';
import '../datasources/passenger_profile_data_source.dart';

class PassengerProfileRepositoryImpl implements PassengerProfileRepository {
  final PassengerProfileRemoteDataSource remoteDataSource;
  final PassengerProfileLocalDataSource localDataSource;

  PassengerProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, PassengerProfile>> getProfile(String userId) async {
    try {
      // Try to get from cache first
      final cachedProfile = await localDataSource.getCachedProfile(userId);
      if (cachedProfile != null) {
        return Right(cachedProfile);
      }

      // If not in cache, get from remote
      final profile = await remoteDataSource.getProfile(userId);

      // Cache the result
      await localDataSource.cacheProfile(profile);

      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(
          UnknownFailure(message: 'Failed to get profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PassengerProfile>> updateProfile(
      String userId, Map<String, dynamic> profileData) async {
    try {
      final updatedProfile =
          await remoteDataSource.updateProfile(userId, profileData);

      // Update cache
      await localDataSource.cacheProfile(updatedProfile);

      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(
          UnknownFailure(message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePreferences(
      String userId, Map<String, bool> preferences) async {
    try {
      final result =
          await remoteDataSource.updatePreferences(userId, preferences);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(
          message: 'Failed to update preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String?>> uploadProfileImage(
      String userId, String imagePath) async {
    try {
      final imageUrl =
          await remoteDataSource.uploadProfileImage(userId, imagePath);
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(
          UnknownFailure(message: 'Failed to upload image: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProfile(String userId) async {
    try {
      final result = await remoteDataSource.deleteProfile(userId);

      // Clear cache
      await localDataSource.clearCache(userId);

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(
          UnknownFailure(message: 'Failed to delete profile: ${e.toString()}'));
    }
  }
}
