import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/live_trip.dart';
import '../repositories/live_tracking_repository.dart';

class GetTripUpdatesUseCase {
  final LiveTrackingRepository repository;

  GetTripUpdatesUseCase(this.repository);

  Stream<Either<Failure, LiveTrip>> call(String tripId) {
    return repository.getTripUpdates(tripId);
  }
}
