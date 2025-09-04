enum PassengerStatus { waiting, pickedUp, droppedOff }

class TripPassenger {
  final String id;
  final String name;
  final String phoneNumber;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime pickupTime;
  final DateTime? actualPickupTime;
  final DateTime? actualDropoffTime;
  final PassengerStatus status;
  final String? notes;

  const TripPassenger({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupTime,
    this.actualPickupTime,
    this.actualDropoffTime,
    required this.status,
    this.notes,
  });

  bool get isWaiting => status == PassengerStatus.waiting;
  bool get isPickedUp => status == PassengerStatus.pickedUp;
  bool get isDroppedOff => status == PassengerStatus.droppedOff;

  TripPassenger copyWith({
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
    return TripPassenger(
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
