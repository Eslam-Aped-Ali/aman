import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../repositories/live_tracking_repository.dart';

class CancelTripUseCase {
  final LiveTrackingRepository repository;

  CancelTripUseCase(this.repository);

  Future<Either<Failure, bool>> call(String tripId) async {
    return await repository.cancelTrip(tripId);
  }
}
