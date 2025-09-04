import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../entities/booking_request.dart';
import '../entities/location_point.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<LocationPoint>>> getPopularLocations();
  Future<Either<Failure, List<LocationPoint>>> searchLocations(String query);
  Future<Either<Failure, BookingRequest>> createBooking(BookingRequest booking);
  Future<Either<Failure, List<BookingRequest>>> getUserBookings();
  Future<Either<Failure, BookingRequest>> getBookingById(String id);
  Future<Either<Failure, BookingRequest>> updateBookingStatus(
      String id, BookingStatus status);
  Future<Either<Failure, Unit>> cancelBooking(String id);
  Future<Either<Failure, LocationPoint>> getCurrentLocation();
  Future<Either<Failure, List<LocationPoint>>> getNearbyLocations(
      double latitude, double longitude);
}
