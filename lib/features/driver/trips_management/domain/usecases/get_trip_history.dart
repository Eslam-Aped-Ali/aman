import '../entities/driver_trip.dart';
import '../repositories/driver_trips_repository.dart';

class GetTripHistoryUseCase {
  final DriverTripsRepository repository;

  GetTripHistoryUseCase(this.repository);

  Future<List<DriverTrip>> call(String driverId) async {
    return await repository.getTripHistory(driverId);
  }
}
