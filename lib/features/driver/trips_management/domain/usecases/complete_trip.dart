import '../entities/driver_trip.dart';
import '../repositories/driver_trips_repository.dart';

class CompleteTripUseCase {
  final DriverTripsRepository repository;

  CompleteTripUseCase(this.repository);

  Future<DriverTrip> call(String tripId) async {
    return await repository.completeTrip(tripId);
  }
}
