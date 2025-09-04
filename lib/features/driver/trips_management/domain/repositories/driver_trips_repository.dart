import '../entities/driver_trip.dart';
import '../entities/trip_passenger.dart';

abstract class DriverTripsRepository {
  Future<List<DriverTrip>> getCurrentTrips(String driverId);
  Future<List<DriverTrip>> getTripHistory(String driverId);
  Future<DriverTrip?> getTripById(String tripId);
  Future<List<TripPassenger>> getTripPassengers(String tripId);
  Future<TripPassenger> updatePassengerStatus(
    String tripId,
    String passengerId,
    PassengerStatus status,
  );
  Future<void> notifyPassengerArrival(String passengerId, String message);
  Future<DriverTrip> startTrip(String tripId);
  Future<DriverTrip> completeTrip(String tripId);
}
