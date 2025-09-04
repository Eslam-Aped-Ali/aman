import '../entities/trip_passenger.dart';
import '../repositories/driver_trips_repository.dart';

class GetTripPassengersUseCase {
  final DriverTripsRepository repository;

  GetTripPassengersUseCase(this.repository);

  Future<List<TripPassenger>> call(String tripId) async {
    return await repository.getTripPassengers(tripId);
  }
}
