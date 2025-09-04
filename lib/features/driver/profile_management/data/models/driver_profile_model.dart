import '../../domain/entities/driver_profile.dart';

class DriverProfileModel extends DriverProfile {
  const DriverProfileModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required super.gender,
    required super.birthYear,
    required super.status,
    required super.createdAt,
    super.approvedAt,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.male,
      ),
      birthYear: json['birthYear'] as int,
      status: DriverStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DriverStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'gender': gender.name,
      'birthYear': birthYear,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  factory DriverProfileModel.fromEntity(DriverProfile profile) {
    return DriverProfileModel(
      id: profile.id,
      name: profile.name,
      phoneNumber: profile.phoneNumber,
      gender: profile.gender,
      birthYear: profile.birthYear,
      status: profile.status,
      createdAt: profile.createdAt,
      approvedAt: profile.approvedAt,
    );
  }

  @override
  DriverProfileModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    Gender? gender,
    int? birthYear,
    DriverStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return DriverProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
