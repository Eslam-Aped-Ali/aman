// lib/domain/usecases/auth/login_usecase.dart
import 'package:Aman/core/shared/error_handling/failures.dart';
import 'package:Aman/core/shared/usecases/usecase_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/repositories/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    final result = await repository.login(
      phone: params.phone,
      password: params.password,
    );

    // Save token if login successful
    return result.fold(
      (failure) => Left(failure),
      (user) async {
        if (user.token != null) {
          await repository.saveToken(user.token!);
        }
        return Right(user);
      },
    );
  }
}

class LoginParams extends Equatable {
  final String phone;
  final String password;

  const LoginParams({
    required this.phone,
    required this.password,
  });

  @override
  List<Object> get props => [phone, password];
}
