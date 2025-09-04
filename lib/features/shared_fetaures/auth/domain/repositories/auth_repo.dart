import 'package:dartz/dartz.dart';
import 'package:Aman/core/shared/error_handling/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  });

  Future<Either<Failure, User>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, String?>> getToken();

  Future<Either<Failure, void>> saveToken(String token);

  Future<Either<Failure, void>> deleteToken();
}
