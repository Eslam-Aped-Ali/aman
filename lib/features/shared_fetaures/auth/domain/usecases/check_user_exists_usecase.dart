// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
// import 'package:Aman/core/shared/error_handling/failures.dart';
// import 'package:Aman/core/shared/usecases/usecase_abstract.dart';
// import '../repositories/auth_repo.dart';

// class CheckUserExistsParams extends Equatable {
//   final String phone;

//   const CheckUserExistsParams({required this.phone});

//   @override
//   List<Object> get props => [phone];
// }

// class CheckUserExistsUseCase extends UseCase<bool, CheckUserExistsParams> {
//   final AuthRepository repository;

//   CheckUserExistsUseCase(this.repository);

//   @override
//   Future<Either<Failure, bool>> call(CheckUserExistsParams params) async {
//     return await repository.checkUserExists(params.phone);
//   }
// }
