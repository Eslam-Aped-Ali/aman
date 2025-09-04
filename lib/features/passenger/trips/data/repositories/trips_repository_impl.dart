import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_filter.dart';
import '../../domain/repositories/trips_repository.dart';
import '../datasources/trips_local_data_source.dart';

class TripsRepositoryImpl implements TripsRepository {
  final TripsLocalDataSource localDataSource;

  TripsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Trip>>> getAvailableTrips(
      [TripFilter? filter]) async {
    try {
      final trips = localDataSource.getAvailableTrips(filter);
      return Right(trips);
    } catch (e) {
      return Left(
          LocalFailure('Failed to load available trips: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> getPopularTrips() async {
    try {
      final trips = localDataSource.getPopularTrips();
      return Right(trips);
    } catch (e) {
      return Left(
          LocalFailure('Failed to load popular trips: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Trip>> getTripById(String id) async {
    try {
      final trip = localDataSource.getTripById(id);
      if (trip != null) {
        return Right(trip);
      } else {
        return Left(NotFoundFailure('Trip with id $id not found'));
      }
    } catch (e) {
      return Left(LocalFailure('Failed to get trip by id: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> searchTrips(String query) async {
    try {
      final trips = localDataSource.searchTrips(query);
      return Right(trips);
    } catch (e) {
      return Left(LocalFailure('Failed to search trips: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLocations() async {
    try {
      final locations = localDataSource.getLocations();
      return Right(locations);
    } catch (e) {
      return Left(LocalFailure('Failed to get locations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBusOperators() async {
    try {
      final operators = localDataSource.getBusOperators();
      return Right(operators);
    } catch (e) {
      return Left(LocalFailure('Failed to get bus operators: ${e.toString()}'));
    }
  }
}
