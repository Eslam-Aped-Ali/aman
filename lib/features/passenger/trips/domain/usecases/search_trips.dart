import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/trip.dart';
import '../repositories/trips_repository.dart';

class SearchTripsUseCase {
  final TripsRepository repository;

  SearchTripsUseCase(this.repository);

  Future<Either<Failure, List<Trip>>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }
    return await repository.searchTrips(query);
  }
}
