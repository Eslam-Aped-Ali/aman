import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/live_trip.dart';
import '../repositories/live_tracking_repository.dart';

class GetMyBookingsUseCase {
  final LiveTrackingRepository repository;

  GetMyBookingsUseCase(this.repository);

  Future<Either<Failure, List<LiveTrip>>> call(String passengerId) async {
    return await repository.getMyBookings(passengerId);
  }
}
