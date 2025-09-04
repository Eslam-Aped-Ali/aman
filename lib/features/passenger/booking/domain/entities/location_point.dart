import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final double latitude;
  final double longitude;
  final String address;
  final String addressAr;
  final String type; // 'pickup' or 'dropoff'
  final bool isUserLocation;
  final DateTime? selectedTime;

  const LocationPoint({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.addressAr,
    required this.type,
    this.isUserLocation = false,
    this.selectedTime,
  });

  LocationPoint copyWith({
    String? id,
    String? name,
    String? nameAr,
    double? latitude,
    double? longitude,
    String? address,
    String? addressAr,
    String? type,
    bool? isUserLocation,
    DateTime? selectedTime,
  }) {
    return LocationPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      addressAr: addressAr ?? this.addressAr,
      type: type ?? this.type,
      isUserLocation: isUserLocation ?? this.isUserLocation,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        latitude,
        longitude,
        address,
        addressAr,
        type,
        isUserLocation,
        selectedTime,
      ];
}
