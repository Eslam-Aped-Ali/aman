import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/live_trip.dart';
import '../repositories/live_tracking_repository.dart';

class GetCurrentTripUseCase {
  final LiveTrackingRepository repository;

  GetCurrentTripUseCase(this.repository);

  Future<Either<Failure, LiveTrip?>> call(String passengerId) async {
    return await repository.getCurrentTrip(passengerId);
  }
}
