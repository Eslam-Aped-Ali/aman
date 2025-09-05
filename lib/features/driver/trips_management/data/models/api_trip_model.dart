// API models that match backend response structure
import '../../domain/entities/driver_trip.dart';

class LocationModel {
  final int id;
  final String address;
  final double latitude;
  final double longitude;
  final String stateName;
  final String cityName;

  const LocationModel({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.stateName,
    required this.cityName,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      stateName: json['stateName'] as String,
      cityName: json['cityName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'stateName': stateName,
      'cityName': cityName,
    };
  }
}

class BusModel {
  final int id;
  final String licenseNumber;
  final String status;
  final String licenseExpiryDate;
  final int capacity;

  const BusModel({
    required this.id,
    required this.licenseNumber,
    required this.status,
    required this.licenseExpiryDate,
    required this.capacity,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id'] as int,
      licenseNumber: json['licenseNumber'] as String,
      status: json['status'] as String,
      licenseExpiryDate: json['licenseExpiryDate'] as String,
      capacity: json['capacity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licenseNumber': licenseNumber,
      'status': status,
      'licenseExpiryDate': licenseExpiryDate,
      'capacity': capacity,
    };
  }
}

class ApiTripModel {
  final int id;
  final LocationModel from;
  final LocationModel to;
  final String tripDate;
  final String tripTime;
  final String status;
  final BusModel bus;
  final int driverId;
  final int bookingCount;

  const ApiTripModel({
    required this.id,
    required this.from,
    required this.to,
    required this.tripDate,
    required this.tripTime,
    required this.status,
    required this.bus,
    required this.driverId,
    required this.bookingCount,
  });

  factory ApiTripModel.fromJson(Map<String, dynamic> json) {
    return ApiTripModel(
      id: json['id'] as int,
      from: LocationModel.fromJson(json['from'] as Map<String, dynamic>),
      to: LocationModel.fromJson(json['to'] as Map<String, dynamic>),
      tripDate: json['tripDate'] as String,
      tripTime: json['tripTime'] as String,
      status: json['status'] as String,
      bus: BusModel.fromJson(json['bus'] as Map<String, dynamic>),
      driverId: json['driverId'] as int,
      bookingCount: json['bookingCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from.toJson(),
      'to': to.toJson(),
      'tripDate': tripDate,
      'tripTime': tripTime,
      'status': status,
      'bus': bus.toJson(),
      'driverId': driverId,
      'bookingCount': bookingCount,
    };
  }

  // Convert to domain entity
  DriverTrip toDomainEntity() {
    // Parse trip date and time
    final tripDateTime = DateTime.parse('$tripDate $tripTime');

    // Map API status to domain status
    DriverTripStatus domainStatus;
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        domainStatus = DriverTripStatus.completed;
        break;
      case 'STARTED':
        domainStatus = DriverTripStatus.started;
        break;
      case 'SCHEDULED':
        domainStatus = DriverTripStatus.scheduled;
        break;
      case 'CANCELLED':
        domainStatus = DriverTripStatus.cancelled;
        break;
      default:
        domainStatus = DriverTripStatus.scheduled; // Default to scheduled
    }

    return DriverTrip(
      id: id.toString(),
      routeName: '${from.cityName} - ${to.cityName} Route',
      fromLocation: from.address,
      toLocation: to.address,
      departureTime: tripDateTime,
      actualDepartureTime:
          status == 'STARTED' || status == 'COMPLETED' ? tripDateTime : null,
      arrivalTime: null, // Calculate based on distance/duration if needed
      actualArrivalTime: status == 'COMPLETED'
          ? tripDateTime.add(const Duration(hours: 2))
          : null,
      status: domainStatus,
      passengers: [], // Will be loaded separately if needed
      busNumber: bus.licenseNumber,
      routeDescription: '${from.address} to ${to.address}',
      totalDistance: 0.0, // Calculate if needed
      estimatedDuration: 120, // Default 2 hours, calculate if needed
      currentDestination: to.address,
      assignedAt: tripDateTime.subtract(const Duration(hours: 1)),
    );
  }
}
