import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String? token;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
  });

  @override
  List<Object?> get props => [id, fullName, email, phone, role, token];
}

enum UserRole {
  PASSENGER,
  DRIVER,
  ADMIN;

  String get value => name;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRole.PASSENGER,
    );
  }
}
