import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/trip.dart';
import '../entities/trip_filter.dart';

abstract class TripsRepository {
  Future<Either<Failure, List<Trip>>> getAvailableTrips([TripFilter? filter]);
  Future<Either<Failure, List<Trip>>> getPopularTrips();
  Future<Either<Failure, Trip>> getTripById(String id);
  Future<Either<Failure, List<Trip>>> searchTrips(String query);
  Future<Either<Failure, List<String>>> getLocations();
  Future<Either<Failure, List<String>>> getBusOperators();
}
