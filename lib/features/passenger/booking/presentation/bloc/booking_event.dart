import 'package:equatable/equatable.dart';
import '../../domain/entities/location_point.dart';
import '../../../trips/domain/entities/trip.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadPopularLocations extends BookingEvent {
  const LoadPopularLocations();
}

class SearchLocations extends BookingEvent {
  final String query;

  const SearchLocations(this.query);

  @override
  List<Object> get props => [query];
}

class SelectPickupLocation extends BookingEvent {
  final LocationPoint location;

  const SelectPickupLocation(this.location);

  @override
  List<Object> get props => [location];
}

class SelectDropoffLocation extends BookingEvent {
  final LocationPoint location;

  const SelectDropoffLocation(this.location);

  @override
  List<Object> get props => [location];
}

class CreateBooking extends BookingEvent {
  final Trip trip;
  final LocationPoint pickupLocation;
  final LocationPoint dropoffLocation;
  final String passengerName;
  final String passengerPhone;
  final String? passengerEmail;
  final String? specialInstructions;
  final String paymentMethod;
  final bool requiresSpecialAssistance;
  final int numberOfPassengers;

  const CreateBooking({
    required this.trip,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.passengerName,
    required this.passengerPhone,
    this.passengerEmail,
    this.specialInstructions,
    required this.paymentMethod,
    this.requiresSpecialAssistance = false,
    this.numberOfPassengers = 1,
  });

  @override
  List<Object?> get props => [
        trip,
        pickupLocation,
        dropoffLocation,
        passengerName,
        passengerPhone,
        passengerEmail,
        specialInstructions,
        paymentMethod,
        requiresSpecialAssistance,
        numberOfPassengers,
      ];
}

class GetCurrentLocation extends BookingEvent {
  const GetCurrentLocation();
}

class ClearSelectedLocations extends BookingEvent {
  const ClearSelectedLocations();
}

class LoadUserBookings extends BookingEvent {
  const LoadUserBookings();
}

class CancelBooking extends BookingEvent {
  final String bookingId;

  const CancelBooking(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
