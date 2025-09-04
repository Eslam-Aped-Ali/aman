import '../entities/trip_passenger.dart';
import '../repositories/driver_trips_repository.dart';

class UpdatePassengerStatusUseCase {
  final DriverTripsRepository repository;

  UpdatePassengerStatusUseCase(this.repository);

  Future<TripPassenger> call(
    String tripId,
    String passengerId,
    PassengerStatus status,
  ) async {
    return await repository.updatePassengerStatus(tripId, passengerId, status);
  }
}
