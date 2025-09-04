enum Gender { male, female }

enum DriverStatus { pending, approved, rejected }

class DriverProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final Gender gender;
  final int birthYear;
  final DriverStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;

  const DriverProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    required this.birthYear,
    required this.status,
    required this.createdAt,
    this.approvedAt,
  });

  bool get isApproved => status == DriverStatus.approved;
  bool get isPending => status == DriverStatus.pending;
  bool get isRejected => status == DriverStatus.rejected;

  int get age => DateTime.now().year - birthYear;

  DriverProfile copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    Gender? gender,
    int? birthYear,
    DriverStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return DriverProfile(
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
