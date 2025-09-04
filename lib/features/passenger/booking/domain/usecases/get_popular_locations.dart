import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/location_point.dart';
import '../repositories/booking_repository.dart';

class GetPopularLocationsUseCase {
  final BookingRepository repository;

  GetPopularLocationsUseCase(this.repository);

  Future<Either<Failure, List<LocationPoint>>> call() {
    return repository.getPopularLocations();
  }
}
