import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../../domain/entities/live_trip.dart';
import '../../domain/repositories/live_tracking_repository.dart';
import '../../../booking/domain/entities/location_point.dart';
import '../datasources/live_tracking_local_data_source.dart';

class LiveTrackingRepositoryImpl implements LiveTrackingRepository {
  final LiveTrackingLocalDataSource localDataSource;

  LiveTrackingRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, LiveTrip?>> getCurrentTrip(String passengerId) async {
    try {
      final result = await localDataSource.getCurrentTrip(passengerId);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to get current trip'));
    }
  }

  @override
  Future<Either<Failure, List<LiveTrip>>> getMyBookings(
      String passengerId) async {
    try {
      final result = await localDataSource.getMyBookings(passengerId);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to get bookings'));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelTrip(String tripId) async {
    try {
      final result = await localDataSource.cancelTrip(tripId);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to cancel trip'));
    }
  }

  @override
  Future<Either<Failure, bool>> contactDriver(
      String driverId, String message) async {
    try {
      final result = await localDataSource.contactDriver(driverId, message);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to contact driver'));
    }
  }

  @override
  Stream<Either<Failure, LiveTrip>> getTripUpdates(String tripId) async* {
    try {
      await for (final trip in localDataSource.getTripUpdates(tripId)) {
        yield Right(trip);
      }
    } catch (e) {
      yield Left(LocalFailure('Failed to get trip updates'));
    }
  }

  @override
  Future<Either<Failure, bool>> rateDriver(
      String tripId, double rating, String? comment) async {
    try {
      final result = await localDataSource.rateDriver(tripId, rating, comment);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to rate driver'));
    }
  }

  @override
  Future<Either<Failure, bool>> reportIssue(
      String tripId, String issue, String description) async {
    try {
      final result =
          await localDataSource.reportIssue(tripId, issue, description);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to report issue'));
    }
  }

  @override
  Future<Either<Failure, List<LocationPoint>>> getTripRoute(
      String tripId) async {
    try {
      final result = await localDataSource.getTripRoute(tripId);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure('Failed to get trip route'));
    }
  }
}
