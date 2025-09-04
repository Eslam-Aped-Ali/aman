import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/trip.dart';
import '../entities/trip_filter.dart';
import '../repositories/trips_repository.dart';

class GetAvailableTripsUseCase {
  final TripsRepository repository;

  GetAvailableTripsUseCase(this.repository);

  Future<Either<Failure, List<Trip>>> call([TripFilter? filter]) async {
    return await repository.getAvailableTrips(filter);
  }
}
