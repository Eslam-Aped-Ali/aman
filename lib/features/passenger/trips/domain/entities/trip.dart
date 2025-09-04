import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final String id;
  final String fromLocation;
  final String toLocation;
  final String fromLocationAr;
  final String toLocationAr;
  final double price;
  final String duration;
  final double rating;
  final String busType;
  final int availableSeats;
  final int totalSeats;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String operatorName;
  final String operatorLogo;
  final List<String> amenities;
  final List<String> stops;
  final bool isDirectRoute;
  final String busNumber;
  final String driverName;
  final String driverPhone;
  final TripStatus status;
  final double discount;
  final bool isPopular;
  final List<String> images;

  const Trip({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    required this.fromLocationAr,
    required this.toLocationAr,
    required this.price,
    required this.duration,
    required this.rating,
    required this.busType,
    required this.availableSeats,
    required this.totalSeats,
    required this.departureTime,
    required this.arrivalTime,
    required this.operatorName,
    required this.operatorLogo,
    required this.amenities,
    required this.stops,
    required this.isDirectRoute,
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.status,
    this.discount = 0.0,
    this.isPopular = false,
    this.images = const [],
  });

  double get finalPrice => price - (price * discount / 100);

  bool get isLowAvailability => availableSeats < 10;

  int get occupiedSeats => totalSeats - availableSeats;

  double get occupancyRate => (occupiedSeats / totalSeats) * 100;

  @override
  List<Object?> get props => [
        id,
        fromLocation,
        toLocation,
        fromLocationAr,
        toLocationAr,
        price,
        duration,
        rating,
        busType,
        availableSeats,
        totalSeats,
        departureTime,
        arrivalTime,
        operatorName,
        operatorLogo,
        amenities,
        stops,
        isDirectRoute,
        busNumber,
        driverName,
        driverPhone,
        status,
        discount,
        isPopular,
        images,
      ];
}

enum TripStatus {
  scheduled,
  boarding,
  inTransit,
  completed,
  cancelled,
  delayed,
}

enum BusType {
  acSleeper,
  acDeluxe,
  ac,
  nonAc,
  luxury,
  express,
}

enum TripAmenity {
  wifi,
  ac,
  charging,
  entertainment,
  meals,
  blanket,
  pillow,
  restroom,
  reading,
  music,
}
