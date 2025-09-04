import '../../domain/entities/live_trip.dart' as LiveTrackingDomain;
import '../../../booking/data/models/location_point_model.dart';
import '../../../trips/data/models/trip_model.dart';

class LiveTripModel extends LiveTrackingDomain.LiveTrip {
  const LiveTripModel({
    required super.id,
    required super.trip,
    required super.pickupLocation,
    required super.dropoffLocation,
    required super.currentDriverLocation,
    required super.status,
    required super.bookingTime,
    super.estimatedArrival,
    super.estimatedDropoff,
    super.driver,
    required super.passengerName,
    required super.passengerPhone,
    required super.totalAmount,
    required super.paymentMethod,
    required super.distance,
    required super.estimatedDuration,
    super.routePoints = const [],
    super.specialInstructions,
    super.isSharedRide = false,
    super.otherPassengersCount,
  });

  factory LiveTripModel.fromJson(Map<String, dynamic> json) {
    return LiveTripModel(
      id: json['id'] ?? '',
      trip: TripModel.fromJson(json['trip'] ?? {}),
      pickupLocation: LocationPointModel.fromJson(json['pickupLocation'] ?? {}),
      dropoffLocation:
          LocationPointModel.fromJson(json['dropoffLocation'] ?? {}),
      currentDriverLocation:
          LocationPointModel.fromJson(json['currentDriverLocation'] ?? {}),
      status: _parseStatus(json['status']),
      bookingTime: DateTime.parse(
          json['bookingTime'] ?? DateTime.now().toIso8601String()),
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.parse(json['estimatedArrival'])
          : null,
      estimatedDropoff: json['estimatedDropoff'] != null
          ? DateTime.parse(json['estimatedDropoff'])
          : null,
      driver: json['driver'] != null
          ? DriverInfoModel.fromJson(json['driver'])
          : null,
      passengerName: json['passengerName'] ?? '',
      passengerPhone: json['passengerPhone'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      distance: (json['distance'] ?? 0.0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      routePoints: (json['routePoints'] as List<dynamic>?)
              ?.map((e) => LocationPointModel.fromJson(e))
              .toList() ??
          [],
      specialInstructions: json['specialInstructions'],
      isSharedRide: json['isSharedRide'] ?? false,
      otherPassengersCount: json['otherPassengersCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip': (trip as TripModel).toJson(),
      'pickupLocation': (pickupLocation as LocationPointModel).toJson(),
      'dropoffLocation': (dropoffLocation as LocationPointModel).toJson(),
      'currentDriverLocation':
          (currentDriverLocation as LocationPointModel).toJson(),
      'status': status.name,
      'bookingTime': bookingTime.toIso8601String(),
      'estimatedArrival': estimatedArrival?.toIso8601String(),
      'estimatedDropoff': estimatedDropoff?.toIso8601String(),
      'driver': (driver as DriverInfoModel?)?.toJson(),
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'routePoints':
          routePoints.map((e) => (e as LocationPointModel).toJson()).toList(),
      'specialInstructions': specialInstructions,
      'isSharedRide': isSharedRide,
      'otherPassengersCount': otherPassengersCount,
    };
  }

  static LiveTrackingDomain.TripStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return LiveTrackingDomain.TripStatus.pending;
      case 'accepted':
        return LiveTrackingDomain.TripStatus.accepted;
      case 'driverenroute':
        return LiveTrackingDomain.TripStatus.driverEnRoute;
      case 'driverarrived':
        return LiveTrackingDomain.TripStatus.driverArrived;
      case 'inprogress':
        return LiveTrackingDomain.TripStatus.inProgress;
      case 'completed':
        return LiveTrackingDomain.TripStatus.completed;
      case 'cancelled':
        return LiveTrackingDomain.TripStatus.cancelled;
      default:
        return LiveTrackingDomain.TripStatus.pending;
    }
  }

  factory LiveTripModel.fromEntity(LiveTrackingDomain.LiveTrip liveTrip) {
    return LiveTripModel(
      id: liveTrip.id,
      trip: liveTrip.trip,
      pickupLocation: liveTrip.pickupLocation,
      dropoffLocation: liveTrip.dropoffLocation,
      currentDriverLocation: liveTrip.currentDriverLocation,
      status: liveTrip.status,
      bookingTime: liveTrip.bookingTime,
      estimatedArrival: liveTrip.estimatedArrival,
      estimatedDropoff: liveTrip.estimatedDropoff,
      driver: liveTrip.driver,
      passengerName: liveTrip.passengerName,
      passengerPhone: liveTrip.passengerPhone,
      totalAmount: liveTrip.totalAmount,
      paymentMethod: liveTrip.paymentMethod,
      distance: liveTrip.distance,
      estimatedDuration: liveTrip.estimatedDuration,
      routePoints: liveTrip.routePoints,
      specialInstructions: liveTrip.specialInstructions,
      isSharedRide: liveTrip.isSharedRide,
      otherPassengersCount: liveTrip.otherPassengersCount,
    );
  }
}

class DriverInfoModel extends LiveTrackingDomain.DriverInfo {
  const DriverInfoModel({
    required super.id,
    required super.name,
    required super.nameAr,
    required super.phone,
    super.profileImage,
    required super.vehicleModel,
    required super.vehicleColor,
    required super.licensePlate,
    required super.rating,
    required super.totalTrips,
    required super.status,
    super.lastSeen,
  });

  factory DriverInfoModel.fromJson(Map<String, dynamic> json) {
    return DriverInfoModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleColor: json['vehicleColor'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      rating: (json['rating'] ?? 5.0).toDouble(),
      totalTrips: json['totalTrips'] ?? 0,
      status: _parseDriverStatus(json['status']),
      lastSeen:
          json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'phone': phone,
      'profileImage': profileImage,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'licensePlate': licensePlate,
      'rating': rating,
      'totalTrips': totalTrips,
      'status': status.name,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  static LiveTrackingDomain.DriverStatus _parseDriverStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return LiveTrackingDomain.DriverStatus.available;
      case 'busy':
        return LiveTrackingDomain.DriverStatus.busy;
      case 'ontrip':
        return LiveTrackingDomain.DriverStatus.onTrip;
      case 'offline':
      default:
        return LiveTrackingDomain.DriverStatus.offline;
    }
  }

  factory DriverInfoModel.fromEntity(LiveTrackingDomain.DriverInfo driverInfo) {
    return DriverInfoModel(
      id: driverInfo.id,
      name: driverInfo.name,
      nameAr: driverInfo.nameAr,
      phone: driverInfo.phone,
      profileImage: driverInfo.profileImage,
      vehicleModel: driverInfo.vehicleModel,
      vehicleColor: driverInfo.vehicleColor,
      licensePlate: driverInfo.licensePlate,
      rating: driverInfo.rating,
      totalTrips: driverInfo.totalTrips,
      status: driverInfo.status,
      lastSeen: driverInfo.lastSeen,
    );
  }
}
