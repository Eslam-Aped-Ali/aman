import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.role,
    super.token,
  });

  // تحويل من JSON إلى نموذج
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.fromString(json['role'].toString().toUpperCase()),
      token: json['token'] as String?,
    );
  }

  // تحويل من النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.value,
      if (token != null) 'token': token,
    };
  }

  // تحويل من Entity إلى Model
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      token: user.token,
    );
  }

  // نسخ مع تعديل
  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
