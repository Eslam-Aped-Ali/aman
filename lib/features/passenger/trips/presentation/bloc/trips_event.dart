import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_filter.dart';

abstract class TripsEvent extends Equatable {
  const TripsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvailableTrips extends TripsEvent {
  final TripFilter? filter;

  const LoadAvailableTrips({this.filter});

  @override
  List<Object?> get props => [filter];
}

class LoadPopularTrips extends TripsEvent {
  const LoadPopularTrips();
}

class SearchTrips extends TripsEvent {
  final String query;

  const SearchTrips(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyFilter extends TripsEvent {
  final TripFilter filter;

  const ApplyFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ClearFilter extends TripsEvent {
  const ClearFilter();
}

class RefreshTrips extends TripsEvent {
  const RefreshTrips();
}
