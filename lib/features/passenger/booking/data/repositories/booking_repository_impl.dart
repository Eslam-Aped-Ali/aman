import 'package:dartz/dartz.dart';
import '../../../../../core/shared/error_handling/failures.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDataSource localDataSource;

  BookingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<LocationPoint>>> getPopularLocations() async {
    try {
      final locations = localDataSource.getPopularLocations();
      return Right(locations);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LocationPoint>>> searchLocations(
      String query) async {
    try {
      final locations = localDataSource.searchLocations(query);
      return Right(locations);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingRequest>> createBooking(
      BookingRequest booking) async {
    try {
      final bookingModel = (booking as dynamic);
      final createdBooking = localDataSource.createBooking(bookingModel);
      return Right(createdBooking);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingRequest>>> getUserBookings() async {
    try {
      final bookings = localDataSource.getUserBookings();
      return Right(bookings);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingRequest>> getBookingById(String id) async {
    try {
      final booking = localDataSource.getBookingById(id);
      if (booking != null) {
        return Right(booking);
      } else {
        return Left(NotFoundFailure('Booking not found'));
      }
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingRequest>> updateBookingStatus(
      String id, BookingStatus status) async {
    try {
      final updatedBooking = localDataSource.updateBookingStatus(id, status);
      return Right(updatedBooking);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelBooking(String id) async {
    try {
      localDataSource.cancelBooking(id);
      return const Right(unit);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LocationPoint>> getCurrentLocation() async {
    try {
      final location = localDataSource.getCurrentLocation();
      return Right(location);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LocationPoint>>> getNearbyLocations(
      double latitude, double longitude) async {
    try {
      final locations = localDataSource.getNearbyLocations(latitude, longitude);
      return Right(locations);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }
}
