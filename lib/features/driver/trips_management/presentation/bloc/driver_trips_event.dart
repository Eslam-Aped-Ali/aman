import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_passenger.dart';

abstract class DriverTripsEvent extends Equatable {
  const DriverTripsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentTrips extends DriverTripsEvent {
  final String driverId;

  const LoadCurrentTrips(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class LoadTripHistory extends DriverTripsEvent {
  final String driverId;

  const LoadTripHistory(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class LoadTripPassengers extends DriverTripsEvent {
  final String tripId;

  const LoadTripPassengers(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class UpdatePassengerStatus extends DriverTripsEvent {
  final String tripId;
  final String passengerId;
  final PassengerStatus status;

  const UpdatePassengerStatus({
    required this.tripId,
    required this.passengerId,
    required this.status,
  });

  @override
  List<Object?> get props => [tripId, passengerId, status];
}

class NotifyPassengerArrival extends DriverTripsEvent {
  final String passengerId;
  final String message;

  const NotifyPassengerArrival({
    required this.passengerId,
    required this.message,
  });

  @override
  List<Object?> get props => [passengerId, message];
}

class StartTrip extends DriverTripsEvent {
  final String tripId;

  const StartTrip(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class CompleteTrip extends DriverTripsEvent {
  final String tripId;

  const CompleteTrip(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class RefreshCurrentTrips extends DriverTripsEvent {
  final String driverId;

  const RefreshCurrentTrips(this.driverId);

  @override
  List<Object?> get props => [driverId];
}
