import '../entities/driver_trip.dart';
import '../repositories/driver_trips_repository.dart';

class StartTripUseCase {
  final DriverTripsRepository repository;

  StartTripUseCase(this.repository);

  Future<DriverTrip> call(String tripId) async {
    return await repository.startTrip(tripId);
  }
}
