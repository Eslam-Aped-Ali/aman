import '../entities/driver_trip.dart';
import '../repositories/driver_trips_repository.dart';

class GetCurrentTripsUseCase {
  final DriverTripsRepository repository;

  GetCurrentTripsUseCase(this.repository);

  Future<List<DriverTrip>> call(String driverId) async {
    return await repository.getCurrentTrips(driverId);
  }
}
