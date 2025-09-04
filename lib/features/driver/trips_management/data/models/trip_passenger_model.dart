import '../../domain/entities/trip_passenger.dart';

class TripPassengerModel extends TripPassenger {
  const TripPassengerModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.pickupLocation,
    required super.dropoffLocation,
    required super.pickupTime,
    super.actualPickupTime,
    super.actualDropoffTime,
    required super.status,
    super.notes,
  });

  factory TripPassengerModel.fromJson(Map<String, dynamic> json) {
    return TripPassengerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      pickupLocation: json['pickupLocation'] as String,
      dropoffLocation: json['dropoffLocation'] as String,
      pickupTime: DateTime.parse(json['pickupTime'] as String),
      actualPickupTime: json['actualPickupTime'] != null
          ? DateTime.parse(json['actualPickupTime'] as String)
          : null,
      actualDropoffTime: json['actualDropoffTime'] != null
          ? DateTime.parse(json['actualDropoffTime'] as String)
          : null,
      status: PassengerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PassengerStatus.waiting,
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupTime': pickupTime.toIso8601String(),
      'actualPickupTime': actualPickupTime?.toIso8601String(),
      'actualDropoffTime': actualDropoffTime?.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  factory TripPassengerModel.fromEntity(TripPassenger passenger) {
    return TripPassengerModel(
      id: passenger.id,
      name: passenger.name,
      phoneNumber: passenger.phoneNumber,
      pickupLocation: passenger.pickupLocation,
      dropoffLocation: passenger.dropoffLocation,
      pickupTime: passenger.pickupTime,
      actualPickupTime: passenger.actualPickupTime,
      actualDropoffTime: passenger.actualDropoffTime,
      status: passenger.status,
      notes: passenger.notes,
    );
  }

  @override
  TripPassengerModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? pickupLocation,
    String? dropoffLocation,
    DateTime? pickupTime,
    DateTime? actualPickupTime,
    DateTime? actualDropoffTime,
    PassengerStatus? status,
    String? notes,
  }) {
    return TripPassengerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupTime: pickupTime ?? this.pickupTime,
      actualPickupTime: actualPickupTime ?? this.actualPickupTime,
      actualDropoffTime: actualDropoffTime ?? this.actualDropoffTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
