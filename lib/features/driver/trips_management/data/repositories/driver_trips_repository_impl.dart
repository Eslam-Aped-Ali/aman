import '../../domain/entities/driver_trip.dart';
import '../../domain/entities/trip_passenger.dart';
import '../../domain/repositories/driver_trips_repository.dart';
import '../datasources/driver_trips_local_data_source.dart';

class DriverTripsRepositoryImpl implements DriverTripsRepository {
  final DriverTripsLocalDataSource localDataSource;

  DriverTripsRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DriverTrip>> getCurrentTrips(String driverId) async {
    return await localDataSource.getCurrentTrips(driverId);
  }

  @override
  Future<List<DriverTrip>> getTripHistory(String driverId) async {
    return await localDataSource.getTripHistory(driverId);
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
}
