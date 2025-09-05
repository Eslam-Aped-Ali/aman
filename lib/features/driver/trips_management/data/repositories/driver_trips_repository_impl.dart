import '../../domain/entities/driver_trip.dart';
import '../../domain/entities/trip_passenger.dart';
import '../../domain/repositories/driver_trips_repository.dart';
import '../datasources/driver_trips_local_data_source.dart';
import '../datasources/driver_trips_remote_data_source.dart';

class DriverTripsRepositoryImpl implements DriverTripsRepository {
  final DriverTripsLocalDataSource localDataSource;
  final DriverTripsRemoteDataSource remoteDataSource;

  DriverTripsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<DriverTrip>> getCurrentTrips(String driverId) async {
    try {
      // Try to get from API first
      final driverIdInt = int.tryParse(driverId) ?? 1;
      final apiTrips = await remoteDataSource.getCurrentTrips(driverIdInt);

      // Convert API models to domain entities
      return apiTrips.map((apiTrip) => apiTrip.toDomainEntity()).toList();
    } catch (e) {
      // Fall back to local data source
      print('Failed to fetch from API, using local data: $e');
      return await localDataSource.getCurrentTrips(driverId);
    }
  }

  @override
  Future<List<DriverTrip>> getTripHistory(String driverId) async {
    try {
      // Try to get completed trips from API first
      final driverIdInt = int.tryParse(driverId) ?? 1;
      final apiTrips = await remoteDataSource.getCompletedTrips(driverIdInt);

      // Convert API models to domain entities
      return apiTrips.map((apiTrip) => apiTrip.toDomainEntity()).toList();
    } catch (e) {
      // Fall back to local data source
      print('Failed to fetch from API, using local data: $e');
      return await localDataSource.getTripHistory(driverId);
    }
  }

  @override
  Future<DriverTrip?> getTripById(String tripId) async {
    return await localDataSource.getTripById(tripId);
  }

  @override
  Future<List<TripPassenger>> getTripPassengers(String tripId) async {
    return await localDataSource.getTripPassengers(tripId);
  }

  @override
  Future<TripPassenger> updatePassengerStatus(
    String tripId,
    String passengerId,
    PassengerStatus status,
  ) async {
    return await localDataSource.updatePassengerStatus(
        tripId, passengerId, status);
  }

  @override
  Future<void> notifyPassengerArrival(
      String passengerId, String message) async {
    return await localDataSource.notifyPassengerArrival(passengerId, message);
  }

  @override
  Future<DriverTrip> startTrip(String tripId) async {
    return await localDataSource.startTrip(tripId);
  }

  @override
  Future<DriverTrip> completeTrip(String tripId) async {
    return await localDataSource.completeTrip(tripId);
  }

  @override
  Future<DriverTrip> updateTripStatus(String tripId, String status) async {
    // For now, use existing methods for start/complete
    // Backend team can add a dedicated updateTripStatus endpoint later
    switch (status.toUpperCase()) {
      case 'STARTED':
        return await localDataSource.startTrip(tripId);
      case 'COMPLETED':
        return await localDataSource.completeTrip(tripId);
      default:
        throw Exception('Status update for $status not implemented yet');
    }
  }
}
