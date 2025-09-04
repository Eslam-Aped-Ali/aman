import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/entities/location_point.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class LocationsLoaded extends BookingState {
  final List<LocationPoint> locations;
  final LocationPoint? selectedPickupLocation;
  final LocationPoint? selectedDropoffLocation;
  final bool isSearching;

  const LocationsLoaded({
    required this.locations,
    this.selectedPickupLocation,
    this.selectedDropoffLocation,
    this.isSearching = false,
  });

  LocationsLoaded copyWith({
    List<LocationPoint>? locations,
    LocationPoint? selectedPickupLocation,
    LocationPoint? selectedDropoffLocation,
    bool? isSearching,
  }) {
    return LocationsLoaded(
      locations: locations ?? this.locations,
      selectedPickupLocation:
          selectedPickupLocation ?? this.selectedPickupLocation,
      selectedDropoffLocation:
          selectedDropoffLocation ?? this.selectedDropoffLocation,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        locations,
        selectedPickupLocation,
        selectedDropoffLocation,
        isSearching,
      ];
}

class BookingCreated extends BookingState {
  final BookingRequest booking;

  const BookingCreated(this.booking);

  @override
  List<Object> get props => [booking];
}

class BookingsLoaded extends BookingState {
  final List<BookingRequest> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

class CurrentLocationLoaded extends BookingState {
  final LocationPoint currentLocation;

  const CurrentLocationLoaded(this.currentLocation);

  @override
  List<Object> get props => [currentLocation];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object> get props => [message];
}

class BookingCancelled extends BookingState {
  final String bookingId;

  const BookingCancelled(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
