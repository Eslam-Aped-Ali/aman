import 'package:equatable/equatable.dart';

class PassengerProfile extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? emergencyContact;
  final String gender;
  final DateTime? birthDate;
  final String? profileImageUrl;
  final bool preferenceNotifications;
  final bool preferenceLocationServices;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PassengerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.emergencyContact,
    required this.gender,
    this.birthDate,
    this.profileImageUrl,
    this.preferenceNotifications = true,
    this.preferenceLocationServices = true,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  String get displayName => fullName.trim().isEmpty ? phone : fullName;

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  bool get hasCompleteProfile {
    return firstName.isNotEmpty && lastName.isNotEmpty && phone.isNotEmpty;
  }

  PassengerProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? emergencyContact,
    String? gender,
    DateTime? birthDate,
    String? profileImageUrl,
    bool? preferenceNotifications,
    bool? preferenceLocationServices,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PassengerProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferenceNotifications:
          preferenceNotifications ?? this.preferenceNotifications,
      preferenceLocationServices:
          preferenceLocationServices ?? this.preferenceLocationServices,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phone,
        email,
        emergencyContact,
        gender,
        birthDate,
        profileImageUrl,
        preferenceNotifications,
        preferenceLocationServices,
        createdAt,
        updatedAt,
      ];
}
