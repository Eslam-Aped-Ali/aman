import 'trip_passenger.dart';

enum DriverTripStatus { assigned, inProgress, completed, cancelled }

class DriverTrip {
  final String id;
  final String routeName;
  final String fromLocation;
  final String toLocation;
  final DateTime departureTime;
  final DateTime? actualDepartureTime;
  final DateTime? arrivalTime;
  final DateTime? actualArrivalTime;
  final DriverTripStatus status;
  final List<TripPassenger> passengers;
  final String busNumber;
  final String routeDescription;
  final double totalDistance;
  final int estimatedDuration; // in minutes
  final String? currentDestination;
  final DateTime assignedAt;

  const DriverTrip({
    required this.id,
    required this.routeName,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    this.actualDepartureTime,
    this.arrivalTime,
    this.actualArrivalTime,
    required this.status,
    required this.passengers,
    required this.busNumber,
    required this.routeDescription,
    required this.totalDistance,
    required this.estimatedDuration,
    this.currentDestination,
    required this.assignedAt,
  });

  bool get isAssigned => status == DriverTripStatus.assigned;
  bool get isInProgress => status == DriverTripStatus.inProgress;
  bool get isCompleted => status == DriverTripStatus.completed;
  bool get isCancelled => status == DriverTripStatus.cancelled;

  bool get isUpcoming => departureTime.isAfter(DateTime.now());
  bool get isCurrent => isInProgress || (isAssigned && !isUpcoming);

  int get totalPassengers => passengers.length;
  int get waitingPassengers => passengers.where((p) => p.isWaiting).length;
  int get pickedUpPassengers => passengers.where((p) => p.isPickedUp).length;
  int get droppedOffPassengers =>
      passengers.where((p) => p.isDroppedOff).length;

  double get completionPercentage {
    if (totalPassengers == 0) return 0.0;
    return (pickedUpPassengers + droppedOffPassengers) / totalPassengers;
  }

  String get statusDisplayText {
    switch (status) {
      case DriverTripStatus.assigned:
        return isUpcoming ? 'Upcoming' : 'Ready to Start';
      case DriverTripStatus.inProgress:
        return 'In Progress';
      case DriverTripStatus.completed:
        return 'Completed';
      case DriverTripStatus.cancelled:
        return 'Cancelled';
    }
  }

  DriverTrip copyWith({
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
    return DriverTrip(
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
