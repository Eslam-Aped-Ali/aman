import 'package:Aman/core/shared/error_handling/failures.dart';
import 'package:Aman/core/shared/usecases/usecase_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/repositories/auth_repo.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
