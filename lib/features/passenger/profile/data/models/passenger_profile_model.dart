import '../../domain/entities/passenger_profile.dart';

class PassengerProfileModel extends PassengerProfile {
  const PassengerProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
    super.email,
    super.emergencyContact,
    required super.gender,
    super.birthDate,
    super.profileImageUrl,
    super.preferenceNotifications,
    super.preferenceLocationServices,
    required super.createdAt,
    super.updatedAt,
  });

  factory PassengerProfileModel.fromJson(Map<String, dynamic> json) {
    return PassengerProfileModel(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      emergencyContact: json['emergency_contact'],
      gender: json['gender'] ?? 'male',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      profileImageUrl: json['profile_image_url'],
      preferenceNotifications: json['preference_notifications'] ?? true,
      preferenceLocationServices: json['preference_location_services'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  factory PassengerProfileModel.fromFirestore(Map<String, dynamic> data) {
    return PassengerProfileModel(
      id: data['id'] ?? data['uid'] ?? '',
      firstName: data['firstName'] ?? data['first_name'] ?? '',
      lastName: data['lastName'] ?? data['last_name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      emergencyContact: data['emergencyContact'] ?? data['emergency_contact'],
      gender: data['gender'] ?? 'male',
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] is String
              ? DateTime.parse(data['birthDate'])
              : (data['birthDate'] as dynamic)?.toDate())
          : null,
      profileImageUrl: data['profileImageUrl'] ?? data['profile_image_url'],
      preferenceNotifications: data['preferenceNotifications'] ??
          data['preference_notifications'] ??
          true,
      preferenceLocationServices: data['preferenceLocationServices'] ??
          data['preference_location_services'] ??
          true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : (data['createdAt'] as dynamic)?.toDate())
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is String
              ? DateTime.parse(data['updatedAt'])
              : (data['updatedAt'] as dynamic)?.toDate())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'emergency_contact': emergencyContact,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'preference_notifications': preferenceNotifications,
      'preference_location_services': preferenceLocationServices,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'emergencyContact': emergencyContact,
      'gender': gender,
      'birthDate': birthDate,
      'profileImageUrl': profileImageUrl,
      'preferenceNotifications': preferenceNotifications,
      'preferenceLocationServices': preferenceLocationServices,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  @override
  PassengerProfileModel copyWith({
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
    return PassengerProfileModel(
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
}
