import '../entities/driver_trip.dart';
import '../repositories/driver_trips_repository.dart';

class GetTripsByStatusParams {
  final String driverId;
  final String status;

  const GetTripsByStatusParams({
    required this.driverId,
    required this.status,
  });
}

class GetTripsByStatusUseCase {
  final DriverTripsRepository repository;

  GetTripsByStatusUseCase(this.repository);

  Future<List<DriverTrip>> call(GetTripsByStatusParams params) async {
    // Map status to appropriate repository method
    switch (params.status.toUpperCase()) {
      case 'COMPLETED':
      case 'CANCELLED':
        // For history statuses, use the API via repository
        return await repository.getTripHistory(params.driverId);
      case 'SCHEDULED':
      case 'STARTED':
        // For current trip statuses, get current trips and filter by status
        final trips = await repository.getCurrentTrips(params.driverId);
        return trips.where((trip) {
          switch (params.status.toUpperCase()) {
            case 'SCHEDULED':
              return trip.isScheduled;
            case 'STARTED':
              return trip.isStarted;
            default:
              return false;
          }
        }).toList();
      default:
        // For any other status, get all current trips and filter
        final trips = await repository.getCurrentTrips(params.driverId);
        return trips
            .where((trip) =>
                trip.status.name.toUpperCase() == params.status.toUpperCase())
            .toList();
    }
  }
}
