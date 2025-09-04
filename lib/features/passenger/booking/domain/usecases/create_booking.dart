import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/booking_request.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<Either<Failure, BookingRequest>> call(BookingRequest booking) {
    return repository.createBooking(booking);
  }
}
