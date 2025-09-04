import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_filter.dart';

abstract class TripsState extends Equatable {
  const TripsState();

  @override
  List<Object?> get props => [];
}

class TripsInitial extends TripsState {
  const TripsInitial();
}

class TripsLoading extends TripsState {
  const TripsLoading();
}

class TripsLoaded extends TripsState {
  final List<Trip> trips;
  final TripFilter? currentFilter;
  final bool isSearching;
  final String? searchQuery;

  const TripsLoaded({
    required this.trips,
    this.currentFilter,
    this.isSearching = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [trips, currentFilter, isSearching, searchQuery];

  TripsLoaded copyWith({
    List<Trip>? trips,
    TripFilter? currentFilter,
    bool? isSearching,
    String? searchQuery,
  }) {
    return TripsLoaded(
      trips: trips ?? this.trips,
      currentFilter: currentFilter ?? this.currentFilter,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TripsError extends TripsState {
  final String message;

  const TripsError(this.message);

  @override
  List<Object?> get props => [message];
}

class TripsEmpty extends TripsState {
  final String message;

  const TripsEmpty({this.message = 'No trips found'});

  @override
  List<Object?> get props => [message];
}
