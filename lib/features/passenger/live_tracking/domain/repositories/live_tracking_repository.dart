import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/live_trip.dart';
import '../../../booking/domain/entities/location_point.dart';

abstract class LiveTrackingRepository {
  /// Get current active trip for a passenger
  Future<Either<Failure, LiveTrip?>> getCurrentTrip(String passengerId);

  /// Get all trips (active and historical) for a passenger
  Future<Either<Failure, List<LiveTrip>>> getMyBookings(String passengerId);

  /// Cancel a trip
  Future<Either<Failure, bool>> cancelTrip(String tripId);

  /// Contact driver
  Future<Either<Failure, bool>> contactDriver(String driverId, String message);

  /// Get real-time updates for a trip
  Stream<Either<Failure, LiveTrip>> getTripUpdates(String tripId);

  /// Rate driver after trip completion
  Future<Either<Failure, bool>> rateDriver(
      String tripId, double rating, String? comment);

  /// Report issue with trip
  Future<Either<Failure, bool>> reportIssue(
      String tripId, String issue, String description);

  /// Get trip route coordinates
  Future<Either<Failure, List<LocationPoint>>> getTripRoute(String tripId);
}
