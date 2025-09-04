import 'package:Aman/core/shared/error_handling/failures.dart';
import 'package:Aman/core/shared/usecases/usecase_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/repositories/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class RegisterUseCase implements UseCase<String, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(RegisterParams params) async {
    return await repository.register(
      fullName: params.fullName,
      email: params.email,
      phone: params.phone,
      password: params.password,
      role: params.role,
    );
  }
}

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final UserRole role;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [fullName, email, phone, password, role];
}
