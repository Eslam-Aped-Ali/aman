import 'package:equatable/equatable.dart';
import '../../../booking/domain/entities/location_point.dart';
import '../../../trips/domain/entities/trip.dart';

enum TripStatus {
  pending,
  accepted,
  driverEnRoute,
  driverArrived,
  inProgress,
  completed,
  cancelled
}

enum DriverStatus { offline, available, busy, onTrip }

class LiveTrip extends Equatable {
  final String id;
  final Trip trip;
  final LocationPoint pickupLocation;
  final LocationPoint dropoffLocation;
  final LocationPoint currentDriverLocation;
  final TripStatus status;
  final DateTime bookingTime;
  final DateTime? estimatedArrival;
  final DateTime? estimatedDropoff;
  final DriverInfo? driver;
  final String passengerName;
  final String passengerPhone;
  final double totalAmount;
  final String paymentMethod;
  final double distance;
  final int estimatedDuration; // in minutes
  final List<LocationPoint> routePoints;
  final String? specialInstructions;
  final bool isSharedRide;
  final int? otherPassengersCount;

  const LiveTrip({
    required this.id,
    required this.trip,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.currentDriverLocation,
    required this.status,
    required this.bookingTime,
    this.estimatedArrival,
    this.estimatedDropoff,
    this.driver,
    required this.passengerName,
    required this.passengerPhone,
    required this.totalAmount,
    required this.paymentMethod,
    required this.distance,
    required this.estimatedDuration,
    this.routePoints = const [],
    this.specialInstructions,
    this.isSharedRide = false,
    this.otherPassengersCount,
  });

  LiveTrip copyWith({
    String? id,
    Trip? trip,
    LocationPoint? pickupLocation,
    LocationPoint? dropoffLocation,
    LocationPoint? currentDriverLocation,
    TripStatus? status,
    DateTime? bookingTime,
    DateTime? estimatedArrival,
    DateTime? estimatedDropoff,
    DriverInfo? driver,
    String? passengerName,
    String? passengerPhone,
    double? totalAmount,
    String? paymentMethod,
    double? distance,
    int? estimatedDuration,
    List<LocationPoint>? routePoints,
    String? specialInstructions,
    bool? isSharedRide,
    int? otherPassengersCount,
  }) {
    return LiveTrip(
      id: id ?? this.id,
      trip: trip ?? this.trip,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      currentDriverLocation:
          currentDriverLocation ?? this.currentDriverLocation,
      status: status ?? this.status,
      bookingTime: bookingTime ?? this.bookingTime,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      estimatedDropoff: estimatedDropoff ?? this.estimatedDropoff,
      driver: driver ?? this.driver,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      distance: distance ?? this.distance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      routePoints: routePoints ?? this.routePoints,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isSharedRide: isSharedRide ?? this.isSharedRide,
      otherPassengersCount: otherPassengersCount ?? this.otherPassengersCount,
    );
  }

  String get statusText {
    switch (status) {
      case TripStatus.pending:
        return 'Looking for driver...';
      case TripStatus.accepted:
        return 'Driver found';
      case TripStatus.driverEnRoute:
        return 'Driver on the way';
      case TripStatus.driverArrived:
        return 'Driver arrived';
      case TripStatus.inProgress:
        return 'Trip in progress';
      case TripStatus.completed:
        return 'Trip completed';
      case TripStatus.cancelled:
        return 'Trip cancelled';
    }
  }

  double get progress {
    switch (status) {
      case TripStatus.pending:
        return 0.1;
      case TripStatus.accepted:
        return 0.3;
      case TripStatus.driverEnRoute:
        return 0.5;
      case TripStatus.driverArrived:
        return 0.7;
      case TripStatus.inProgress:
        return 0.9;
      case TripStatus.completed:
        return 1.0;
      case TripStatus.cancelled:
        return 0.0;
    }
  }

  bool get canCancel {
    return status == TripStatus.pending ||
        status == TripStatus.accepted ||
        status == TripStatus.driverEnRoute;
  }

  bool get canContactDriver {
    return driver != null &&
        (status == TripStatus.accepted ||
            status == TripStatus.driverEnRoute ||
            status == TripStatus.driverArrived ||
            status == TripStatus.inProgress);
  }

  bool get isActive {
    return status != TripStatus.completed && status != TripStatus.cancelled;
  }

  @override
  List<Object?> get props => [
        id,
        trip,
        pickupLocation,
        dropoffLocation,
        currentDriverLocation,
        status,
        bookingTime,
        estimatedArrival,
        estimatedDropoff,
        driver,
        passengerName,
        passengerPhone,
        totalAmount,
        paymentMethod,
        distance,
        estimatedDuration,
        routePoints,
        specialInstructions,
        isSharedRide,
        otherPassengersCount,
      ];
}

class DriverInfo extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String phone;
  final String? profileImage;
  final String vehicleModel;
  final String vehicleColor;
  final String licensePlate;
  final double rating;
  final int totalTrips;
  final DriverStatus status;
  final DateTime? lastSeen;

  const DriverInfo({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.phone,
    this.profileImage,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.licensePlate,
    required this.rating,
    required this.totalTrips,
    required this.status,
    this.lastSeen,
  });

  DriverInfo copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? phone,
    String? profileImage,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    double? rating,
    int? totalTrips,
    DriverStatus? status,
    DateTime? lastSeen,
  }) {
    return DriverInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      licensePlate: licensePlate ?? this.licensePlate,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  String get displayName => name;
  String get displayNameAr => nameAr;

  String get vehicleInfo => '$vehicleColor $vehicleModel';
  String get ratingText => rating.toStringAsFixed(1);

  bool get isOnline => status != DriverStatus.offline;

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        phone,
        profileImage,
        vehicleModel,
        vehicleColor,
        licensePlate,
        rating,
        totalTrips,
        status,
        lastSeen,
      ];
}
