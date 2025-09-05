import '../entities/driver_trip.dart';
import '../repositories/driver_trips_repository.dart';

class UpdateTripStatusParams {
  final String tripId;
  final String status; // SCHEDULED, STARTED, COMPLETED, CANCELLED

  const UpdateTripStatusParams({
    required this.tripId,
    required this.status,
  });
}

class UpdateTripStatusUseCase {
  final DriverTripsRepository repository;

  UpdateTripStatusUseCase(this.repository);

  Future<DriverTrip> call(UpdateTripStatusParams params) async {
    return await repository.updateTripStatus(params.tripId, params.status);
  }
}
