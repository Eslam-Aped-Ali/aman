import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/location_point.dart';
import '../repositories/booking_repository.dart';

class SearchLocationsUseCase {
  final BookingRepository repository;

  SearchLocationsUseCase(this.repository);

  Future<Either<Failure, List<LocationPoint>>> call(String query) {
    return repository.searchLocations(query);
  }
}
