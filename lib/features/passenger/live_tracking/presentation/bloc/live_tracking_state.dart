import 'package:equatable/equatable.dart';
import '../../domain/entities/live_trip.dart';
import '../../../booking/domain/entities/location_point.dart';

abstract class LiveTrackingState extends Equatable {
  const LiveTrackingState();

  @override
  List<Object?> get props => [];
}

class LiveTrackingInitial extends LiveTrackingState {}

class LiveTrackingLoading extends LiveTrackingState {}

class LiveTrackingError extends LiveTrackingState {
  final String message;

  const LiveTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

class CurrentTripLoaded extends LiveTrackingState {
  final LiveTrip? currentTrip;

  const CurrentTripLoaded(this.currentTrip);

  @override
  List<Object?> get props => [currentTrip];
}

class MyBookingsLoaded extends LiveTrackingState {
  final List<LiveTrip> bookings;
  final LiveTrip? currentTrip;

  const MyBookingsLoaded(this.bookings, [this.currentTrip]);

  @override
  List<Object?> get props => [bookings, currentTrip];
}

class TripTrackingActive extends LiveTrackingState {
  final LiveTrip currentTrip;
  final List<LocationPoint>? route;

  const TripTrackingActive(this.currentTrip, [this.route]);

  @override
  List<Object?> get props => [currentTrip, route];
}

class TripCancelled extends LiveTrackingState {
  final String tripId;

  const TripCancelled(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class DriverContacted extends LiveTrackingState {
  final String driverId;

  const DriverContacted(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class DriverRated extends LiveTrackingState {
  final String tripId;
  final double rating;

  const DriverRated(this.tripId, this.rating);

  @override
  List<Object?> get props => [tripId, rating];
}

class IssueReported extends LiveTrackingState {
  final String tripId;
  final String issue;

  const IssueReported(this.tripId, this.issue);

  @override
  List<Object?> get props => [tripId, issue];
}

class TripRouteLoaded extends LiveTrackingState {
  final List<LocationPoint> route;
  final LiveTrip? currentTrip;

  const TripRouteLoaded(this.route, [this.currentTrip]);

  @override
  List<Object?> get props => [route, currentTrip];
}

class LiveTrackingSuccess extends LiveTrackingState {
  final String message;

  const LiveTrackingSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
