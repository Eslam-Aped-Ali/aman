import '../models/trip_model.dart';
import '../../domain/entities/trip_filter.dart';

abstract class TripsLocalDataSource {
  List<TripModel> getAvailableTrips([TripFilter? filter]);
  List<TripModel> getPopularTrips();
  TripModel? getTripById(String id);
  List<TripModel> searchTrips(String query);
  List<String> getLocations();
  List<String> getBusOperators();
}

class TripsLocalDataSourceImpl implements TripsLocalDataSource {
  final List<TripModel> _trips = TripModel.getDummyTrips();
  final List<String> _locations = TripModel.getDummyLocations();
  final List<String> _operators = TripModel.getDummyOperators();

  @override
  List<TripModel> getAvailableTrips([TripFilter? filter]) {
    var trips = List<TripModel>.from(_trips);

    if (filter != null) {
      // Apply filters
      if (filter.fromLocation != null) {
        trips = trips
            .where((trip) =>
                trip.fromLocation.toLowerCase() ==
                filter.fromLocation!.toLowerCase())
            .toList();
      }

      if (filter.toLocation != null) {
        trips = trips
            .where((trip) =>
                trip.toLocation.toLowerCase() ==
                filter.toLocation!.toLowerCase())
            .toList();
      }

      if (filter.minPrice != null) {
        trips =
            trips.where((trip) => trip.finalPrice >= filter.minPrice!).toList();
      }

      if (filter.maxPrice != null) {
        trips =
            trips.where((trip) => trip.finalPrice <= filter.maxPrice!).toList();
      }

      if (filter.busTypes.isNotEmpty) {
        trips = trips
            .where((trip) => filter.busTypes
                .any((type) => type.toString().split('.').last == trip.busType))
            .toList();
      }

      if (filter.minRating != null) {
        trips =
            trips.where((trip) => trip.rating >= filter.minRating!).toList();
      }

      if (filter.directRouteOnly == true) {
        trips = trips.where((trip) => trip.isDirectRoute).toList();
      }

      if (filter.departureTimeRange != null) {
        trips = trips
            .where((trip) =>
                filter.departureTimeRange!.contains(trip.departureTime))
            .toList();
      }

      if (filter.operators.isNotEmpty) {
        trips = trips
            .where((trip) => filter.operators.contains(trip.operatorName))
            .toList();
      }

      if (filter.requiredAmenities.isNotEmpty) {
        trips = trips.where((trip) {
          final tripAmenities =
              trip.amenities.map((a) => a.toLowerCase()).toSet();
          final requiredAmenities = filter.requiredAmenities
              .map((a) => a.toString().split('.').last.toLowerCase())
              .toSet();
          return requiredAmenities
              .every((required) => tripAmenities.contains(required));
        }).toList();
      }

      // Apply sorting
      switch (filter.sortBy) {
        case TripSortBy.price:
          trips.sort((a, b) => filter.sortOrder == SortOrder.ascending
              ? a.finalPrice.compareTo(b.finalPrice)
              : b.finalPrice.compareTo(a.finalPrice));
          break;
        case TripSortBy.duration:
          trips.sort((a, b) {
            final aDuration = _parseDuration(a.duration);
            final bDuration = _parseDuration(b.duration);
            return filter.sortOrder == SortOrder.ascending
                ? aDuration.compareTo(bDuration)
                : bDuration.compareTo(aDuration);
          });
          break;
        case TripSortBy.departureTime:
          trips.sort((a, b) => filter.sortOrder == SortOrder.ascending
              ? a.departureTime.compareTo(b.departureTime)
              : b.departureTime.compareTo(a.departureTime));
          break;
        case TripSortBy.rating:
          trips.sort((a, b) => filter.sortOrder == SortOrder.ascending
              ? a.rating.compareTo(b.rating)
              : b.rating.compareTo(a.rating));
          break;
        case TripSortBy.availability:
          trips.sort((a, b) => filter.sortOrder == SortOrder.ascending
              ? a.availableSeats.compareTo(b.availableSeats)
              : b.availableSeats.compareTo(a.availableSeats));
          break;
        case TripSortBy.arrivalTime:
          trips.sort((a, b) => filter.sortOrder == SortOrder.ascending
              ? a.arrivalTime.compareTo(b.arrivalTime)
              : b.arrivalTime.compareTo(a.arrivalTime));
          break;
      }
    }

    return trips;
  }

  @override
  List<TripModel> getPopularTrips() {
    return _trips.where((trip) => trip.isPopular).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  @override
  TripModel? getTripById(String id) {
    try {
      return _trips.firstWhere((trip) => trip.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<TripModel> searchTrips(String query) {
    final searchQuery = query.toLowerCase();
    return _trips.where((trip) {
      return trip.fromLocation.toLowerCase().contains(searchQuery) ||
          trip.toLocation.toLowerCase().contains(searchQuery) ||
          trip.fromLocationAr.contains(searchQuery) ||
          trip.toLocationAr.contains(searchQuery) ||
          trip.operatorName.toLowerCase().contains(searchQuery) ||
          trip.busNumber.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  List<String> getLocations() {
    return List<String>.from(_locations);
  }

  @override
  List<String> getBusOperators() {
    return List<String>.from(_operators);
  }

  int _parseDuration(String duration) {
    // Parse duration like "1h 45m" to minutes
    final regex = RegExp(r'(\d+)h\s*(\d+)m');
    final match = regex.firstMatch(duration);
    if (match != null) {
      final hours = int.parse(match.group(1) ?? '0');
      final minutes = int.parse(match.group(2) ?? '0');
      return hours * 60 + minutes;
    }
    return 0;
  }
}
