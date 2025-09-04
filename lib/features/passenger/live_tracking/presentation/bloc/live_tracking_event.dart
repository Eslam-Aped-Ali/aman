import 'package:equatable/equatable.dart';
import '../../domain/entities/live_trip.dart';

abstract class LiveTrackingEvent extends Equatable {
  const LiveTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentTrip extends LiveTrackingEvent {
  final String passengerId;

  const LoadCurrentTrip(this.passengerId);

  @override
  List<Object?> get props => [passengerId];
}

class LoadMyBookings extends LiveTrackingEvent {
  final String passengerId;

  const LoadMyBookings(this.passengerId);

  @override
  List<Object?> get props => [passengerId];
}

class CancelTrip extends LiveTrackingEvent {
  final String tripId;

  const CancelTrip(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class ContactDriver extends LiveTrackingEvent {
  final String driverId;
  final String message;

  const ContactDriver(this.driverId, this.message);

  @override
  List<Object?> get props => [driverId, message];
}

class StartTripTracking extends LiveTrackingEvent {
  final String tripId;

  const StartTripTracking(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class StopTripTracking extends LiveTrackingEvent {
  const StopTripTracking();
}

class RateDriver extends LiveTrackingEvent {
  final String tripId;
  final double rating;
  final String? comment;

  const RateDriver(this.tripId, this.rating, [this.comment]);

  @override
  List<Object?> get props => [tripId, rating, comment];
}

class ReportIssue extends LiveTrackingEvent {
  final String tripId;
  final String issue;
  final String description;

  const ReportIssue(this.tripId, this.issue, this.description);

  @override
  List<Object?> get props => [tripId, issue, description];
}

class LoadTripRoute extends LiveTrackingEvent {
  final String tripId;

  const LoadTripRoute(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class RefreshCurrentTrip extends LiveTrackingEvent {
  final String passengerId;

  const RefreshCurrentTrip(this.passengerId);

  @override
  List<Object?> get props => [passengerId];
}

class SelectBookingForTracking extends LiveTrackingEvent {
  final LiveTrip trip;

  const SelectBookingForTracking(this.trip);

  @override
  List<Object?> get props => [trip];
}
