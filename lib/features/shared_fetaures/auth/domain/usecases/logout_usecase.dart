// lib/domain/usecases/auth/logout_usecase.dart
import 'package:Aman/core/shared/error_handling/failures.dart';
import 'package:Aman/core/shared/usecases/usecase_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/repositories/auth_repo.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
