import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/location_point.dart';
import '../repositories/booking_repository.dart';

class GetCurrentLocationUseCase {
  final BookingRepository repository;

  GetCurrentLocationUseCase(this.repository);

  Future<Either<Failure, LocationPoint>> call() {
    return repository.getCurrentLocation();
  }
}
