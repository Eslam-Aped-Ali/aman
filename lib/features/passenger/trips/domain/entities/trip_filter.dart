import 'package:equatable/equatable.dart';
import 'trip.dart';

class TripFilter extends Equatable {
  final String? fromLocation;
  final String? toLocation;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final double? minPrice;
  final double? maxPrice;
  final List<BusType> busTypes;
  final List<TripAmenity> requiredAmenities;
  final List<String> operators;
  final TimeRange? departureTimeRange;
  final double? minRating;
  final bool? directRouteOnly;
  final TripSortBy sortBy;
  final SortOrder sortOrder;

  const TripFilter({
    this.fromLocation,
    this.toLocation,
    this.departureDate,
    this.returnDate,
    this.minPrice,
    this.maxPrice,
    this.busTypes = const [],
    this.requiredAmenities = const [],
    this.operators = const [],
    this.departureTimeRange,
    this.minRating,
    this.directRouteOnly,
    this.sortBy = TripSortBy.price,
    this.sortOrder = SortOrder.ascending,
  });

  TripFilter copyWith({
    String? fromLocation,
    String? toLocation,
    DateTime? departureDate,
    DateTime? returnDate,
    double? minPrice,
    double? maxPrice,
    List<BusType>? busTypes,
    List<TripAmenity>? requiredAmenities,
    List<String>? operators,
    TimeRange? departureTimeRange,
    double? minRating,
    bool? directRouteOnly,
    TripSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return TripFilter(
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      busTypes: busTypes ?? this.busTypes,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      operators: operators ?? this.operators,
      departureTimeRange: departureTimeRange ?? this.departureTimeRange,
      minRating: minRating ?? this.minRating,
      directRouteOnly: directRouteOnly ?? this.directRouteOnly,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  TripFilter clear() {
    return const TripFilter();
  }

  bool get hasFilters =>
      fromLocation != null ||
      toLocation != null ||
      departureDate != null ||
      returnDate != null ||
      minPrice != null ||
      maxPrice != null ||
      busTypes.isNotEmpty ||
      requiredAmenities.isNotEmpty ||
      operators.isNotEmpty ||
      departureTimeRange != null ||
      minRating != null ||
      directRouteOnly != null;

  @override
  List<Object?> get props => [
        fromLocation,
        toLocation,
        departureDate,
        returnDate,
        minPrice,
        maxPrice,
        busTypes,
        requiredAmenities,
        operators,
        departureTimeRange,
        minRating,
        directRouteOnly,
        sortBy,
        sortOrder,
      ];
}

class TimeRange extends Equatable {
  final int startHour;
  final int endHour;

  const TimeRange({
    required this.startHour,
    required this.endHour,
  });

  bool contains(DateTime time) {
    final hour = time.hour;
    return hour >= startHour && hour <= endHour;
  }

  @override
  List<Object?> get props => [startHour, endHour];
}

enum TripSortBy {
  price,
  duration,
  departureTime,
  arrivalTime,
  rating,
  availability,
}

enum SortOrder {
  ascending,
  descending,
}
