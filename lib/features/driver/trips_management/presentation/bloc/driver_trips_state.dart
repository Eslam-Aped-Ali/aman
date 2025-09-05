import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_trip.dart';
import '../../domain/entities/trip_passenger.dart';

abstract class DriverTripsState extends Equatable {
  const DriverTripsState();

  @override
  List<Object?> get props => [];
}

class DriverTripsInitial extends DriverTripsState {}

class DriverTripsLoading extends DriverTripsState {}

class CurrentTripsLoaded extends DriverTripsState {
  final List<DriverTrip> trips;

  const CurrentTripsLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class TripHistoryLoaded extends DriverTripsState {
  final List<DriverTrip> trips;

  const TripHistoryLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class TripPassengersLoaded extends DriverTripsState {
  final List<TripPassenger> passengers;
  final String tripId;

  const TripPassengersLoaded({
    required this.passengers,
    required this.tripId,
  });

  @override
  List<Object?> get props => [passengers, tripId];
}

class PassengerStatusUpdated extends DriverTripsState {
  final TripPassenger passenger;

  const PassengerStatusUpdated(this.passenger);

  @override
  List<Object?> get props => [passenger];
}

class TripStarted extends DriverTripsState {
  final DriverTrip trip;

  const TripStarted(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripCompleted extends DriverTripsState {
  final DriverTrip trip;

  const TripCompleted(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripStatusUpdated extends DriverTripsState {
  final DriverTrip trip;
  final String status;

  const TripStatusUpdated(this.trip, this.status);

  @override
  List<Object?> get props => [trip, status];
}

class PassengerNotified extends DriverTripsState {
  final String message;

  const PassengerNotified(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverTripsError extends DriverTripsState {
  final String message;

  const DriverTripsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverTripsEmpty extends DriverTripsState {
  final String message;

  const DriverTripsEmpty([this.message = 'No trips found']);

  @override
  List<Object?> get props => [message];
}
