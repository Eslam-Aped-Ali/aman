import '../../domain/entities/driver_trip.dart';
import '../../domain/entities/trip_passenger.dart';
import 'trip_passenger_model.dart';

class DriverTripModel extends DriverTrip {
  const DriverTripModel({
    required super.id,
    required super.routeName,
    required super.fromLocation,
    required super.toLocation,
    required super.departureTime,
    super.actualDepartureTime,
    super.arrivalTime,
    super.actualArrivalTime,
    required super.status,
    required super.passengers,
    required super.busNumber,
    required super.routeDescription,
    required super.totalDistance,
    required super.estimatedDuration,
    super.currentDestination,
    required super.assignedAt,
  });

  factory DriverTripModel.fromJson(Map<String, dynamic> json) {
    return DriverTripModel(
      id: json['id'] as String,
      routeName: json['routeName'] as String,
      fromLocation: json['fromLocation'] as String,
      toLocation: json['toLocation'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      actualDepartureTime: json['actualDepartureTime'] != null
          ? DateTime.parse(json['actualDepartureTime'] as String)
          : null,
      arrivalTime: json['arrivalTime'] != null
          ? DateTime.parse(json['arrivalTime'] as String)
          : null,
      actualArrivalTime: json['actualArrivalTime'] != null
          ? DateTime.parse(json['actualArrivalTime'] as String)
          : null,
      status: DriverTripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DriverTripStatus.scheduled,
      ),
      passengers: (json['passengers'] as List<dynamic>)
          .map((p) => TripPassengerModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      busNumber: json['busNumber'] as String,
      routeDescription: json['routeDescription'] as String,
      totalDistance: (json['totalDistance'] as num).toDouble(),
      estimatedDuration: json['estimatedDuration'] as int,
      currentDestination: json['currentDestination'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeName': routeName,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'departureTime': departureTime.toIso8601String(),
      'actualDepartureTime': actualDepartureTime?.toIso8601String(),
      'arrivalTime': arrivalTime?.toIso8601String(),
      'actualArrivalTime': actualArrivalTime?.toIso8601String(),
      'status': status.name,
      'passengers': passengers
          .map((p) => TripPassengerModel.fromEntity(p).toJson())
          .toList(),
      'busNumber': busNumber,
      'routeDescription': routeDescription,
      'totalDistance': totalDistance,
      'estimatedDuration': estimatedDuration,
      'currentDestination': currentDestination,
      'assignedAt': assignedAt.toIso8601String(),
    };
  }

  factory DriverTripModel.fromEntity(DriverTrip trip) {
    return DriverTripModel(
      id: trip.id,
      routeName: trip.routeName,
      fromLocation: trip.fromLocation,
      toLocation: trip.toLocation,
      departureTime: trip.departureTime,
      actualDepartureTime: trip.actualDepartureTime,
      arrivalTime: trip.arrivalTime,
      actualArrivalTime: trip.actualArrivalTime,
      status: trip.status,
      passengers: trip.passengers,
      busNumber: trip.busNumber,
      routeDescription: trip.routeDescription,
      totalDistance: trip.totalDistance,
      estimatedDuration: trip.estimatedDuration,
      currentDestination: trip.currentDestination,
      assignedAt: trip.assignedAt,
    );
  }

  @override
  DriverTripModel copyWith({
    String? id,
    String? routeName,
    String? fromLocation,
    String? toLocation,
    DateTime? departureTime,
    DateTime? actualDepartureTime,
    DateTime? arrivalTime,
    DateTime? actualArrivalTime,
    DriverTripStatus? status,
    List<TripPassenger>? passengers,
    String? busNumber,
    String? routeDescription,
    double? totalDistance,
    int? estimatedDuration,
    String? currentDestination,
    DateTime? assignedAt,
  }) {
    return DriverTripModel(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      departureTime: departureTime ?? this.departureTime,
      actualDepartureTime: actualDepartureTime ?? this.actualDepartureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      actualArrivalTime: actualArrivalTime ?? this.actualArrivalTime,
      status: status ?? this.status,
      passengers: passengers ?? this.passengers,
      busNumber: busNumber ?? this.busNumber,
      routeDescription: routeDescription ?? this.routeDescription,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      currentDestination: currentDestination ?? this.currentDestination,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }
}
