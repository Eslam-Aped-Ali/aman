import '../repositories/driver_trips_repository.dart';

class NotifyPassengerArrivalUseCase {
  final DriverTripsRepository repository;

  NotifyPassengerArrivalUseCase(this.repository);

  Future<void> call(String passengerId, String message) async {
    return await repository.notifyPassengerArrival(passengerId, message);
  }
}
