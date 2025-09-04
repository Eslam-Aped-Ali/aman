import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/trip.dart';
import '../repositories/trips_repository.dart';

class GetPopularTripsUseCase {
  final TripsRepository repository;

  GetPopularTripsUseCase(this.repository);

  Future<Either<Failure, List<Trip>>> call() async {
    return await repository.getPopularTrips();
  }
}
