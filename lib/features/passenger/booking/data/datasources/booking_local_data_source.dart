import 'dart:math' as math;

import '../models/booking_request_model.dart';
import '../models/location_point_model.dart';
import '../../domain/entities/booking_request.dart';

abstract class BookingLocalDataSource {
  List<LocationPointModel> getPopularLocations();
  List<LocationPointModel> searchLocations(String query);
  BookingRequestModel createBooking(BookingRequestModel booking);
  List<BookingRequestModel> getUserBookings();
  BookingRequestModel? getBookingById(String id);
  BookingRequestModel updateBookingStatus(String id, status);
  void cancelBooking(String id);
  LocationPointModel getCurrentLocation();
  List<LocationPointModel> getNearbyLocations(
      double latitude, double longitude);
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  final List<BookingRequestModel> _bookings =
      BookingRequestModel.getDummyBookings();
  final List<LocationPointModel> _locations =
      LocationPointModel.getDummyAllLocations();

  @override
  List<LocationPointModel> getPopularLocations() {
    return LocationPointModel.getDummyPopularLocations();
  }

  @override
  List<LocationPointModel> searchLocations(String query) {
    if (query.isEmpty) return getPopularLocations();

    final lowercaseQuery = query.toLowerCase();

    return _locations.where((location) {
      return location.name.toLowerCase().contains(lowercaseQuery) ||
          location.nameAr.contains(query) ||
          location.address.toLowerCase().contains(lowercaseQuery) ||
          location.addressAr.contains(query);
    }).toList();
  }

  @override
  BookingRequestModel createBooking(BookingRequestModel booking) {
    final newBooking = booking.copyWith(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    _bookings.add(newBooking);
    return newBooking;
  }

  @override
  List<BookingRequestModel> getUserBookings() {
    // Sort by creation date, newest first
    final sortedBookings = List<BookingRequestModel>.from(_bookings);
    sortedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedBookings;
  }

  @override
  BookingRequestModel? getBookingById(String id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  BookingRequestModel updateBookingStatus(String id, status) {
    final bookingIndex = _bookings.indexWhere((booking) => booking.id == id);
    if (bookingIndex == -1) {
      throw Exception('Booking not found');
    }

    final updatedBooking = _bookings[bookingIndex].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    _bookings[bookingIndex] = updatedBooking;
    return updatedBooking;
  }

  @override
  void cancelBooking(String id) {
    final bookingIndex = _bookings.indexWhere((booking) => booking.id == id);
    if (bookingIndex == -1) {
      throw Exception('Booking not found');
    }

    final cancelledBooking = _bookings[bookingIndex].copyWith(
      status: BookingStatus.cancelled,
      updatedAt: DateTime.now(),
    );

    _bookings[bookingIndex] = cancelledBooking;
  }

  @override
  LocationPointModel getCurrentLocation() {
    // Simulate current location (Muscat area)
    return const LocationPointModel(
      id: 'current_location',
      name: 'Current Location',
      nameAr: 'الموقع الحالي',
      latitude: 23.5880,
      longitude: 58.3829,
      address: 'Muscat, Oman',
      addressAr: 'مسقط، عمان',
      type: 'current',
      isUserLocation: true,
    );
  }

  @override
  List<LocationPointModel> getNearbyLocations(
      double latitude, double longitude) {
    // Simple distance calculation for nearby locations
    const double maxDistance = 50.0; // km

    return _locations.where((location) {
      final distance = _calculateDistance(
          latitude, longitude, location.latitude, location.longitude);
      return distance <= maxDistance;
    }).toList()
      ..sort((a, b) {
        final distanceA =
            _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distanceB =
            _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });
  }

  // Simple distance calculation using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
