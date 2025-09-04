import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_available_trips.dart';
import '../../domain/usecases/get_popular_trips.dart';
import '../../domain/usecases/search_trips.dart';
import 'trips_event.dart';
import 'trips_state.dart';

class TripsBloc extends Bloc<TripsEvent, TripsState> {
  final GetAvailableTripsUseCase getAvailableTripsUseCase;
  final GetPopularTripsUseCase getPopularTripsUseCase;
  final SearchTripsUseCase searchTripsUseCase;

  TripsBloc({
    required this.getAvailableTripsUseCase,
    required this.getPopularTripsUseCase,
    required this.searchTripsUseCase,
  }) : super(const TripsInitial()) {
    on<LoadAvailableTrips>(_onLoadAvailableTrips);
    on<LoadPopularTrips>(_onLoadPopularTrips);
    on<SearchTrips>(_onSearchTrips);
    on<ApplyFilter>(_onApplyFilter);
    on<ClearFilter>(_onClearFilter);
    on<RefreshTrips>(_onRefreshTrips);
  }

  Future<void> _onLoadAvailableTrips(
      LoadAvailableTrips event, Emitter<TripsState> emit) async {
    emit(const TripsLoading());

    final result = await getAvailableTripsUseCase(event.filter);

    result.fold(
      (failure) => emit(TripsError(failure.message)),
      (trips) {
        if (trips.isEmpty) {
          emit(const TripsEmpty(message: 'No trips available'));
        } else {
          emit(TripsLoaded(
            trips: trips,
            currentFilter: event.filter,
          ));
        }
      },
    );
  }

  Future<void> _onLoadPopularTrips(
      LoadPopularTrips event, Emitter<TripsState> emit) async {
    emit(const TripsLoading());

    final result = await getPopularTripsUseCase();

    result.fold(
      (failure) => emit(TripsError(failure.message)),
      (trips) {
        if (trips.isEmpty) {
          emit(const TripsEmpty(message: 'No popular trips found'));
        } else {
          emit(TripsLoaded(trips: trips));
        }
      },
    );
  }

  Future<void> _onSearchTrips(
      SearchTrips event, Emitter<TripsState> emit) async {
    if (event.query.trim().isEmpty) {
      // Load all available trips when search is empty
      add(const LoadAvailableTrips());
      return;
    }

    emit(const TripsLoading());

    final result = await searchTripsUseCase(event.query);

    result.fold(
      (failure) => emit(TripsError(failure.message)),
      (trips) {
        if (trips.isEmpty) {
          emit(const TripsEmpty(message: 'No trips found for your search'));
        } else {
          emit(TripsLoaded(
            trips: trips,
            isSearching: true,
            searchQuery: event.query,
          ));
        }
      },
    );
  }

  Future<void> _onApplyFilter(
      ApplyFilter event, Emitter<TripsState> emit) async {
    emit(const TripsLoading());

    final result = await getAvailableTripsUseCase(event.filter);

    result.fold(
      (failure) => emit(TripsError(failure.message)),
      (trips) {
        if (trips.isEmpty) {
          emit(const TripsEmpty(message: 'No trips match your filters'));
        } else {
          emit(TripsLoaded(
            trips: trips,
            currentFilter: event.filter,
          ));
        }
      },
    );
  }

  Future<void> _onClearFilter(
      ClearFilter event, Emitter<TripsState> emit) async {
    add(const LoadAvailableTrips());
  }

  Future<void> _onRefreshTrips(
      RefreshTrips event, Emitter<TripsState> emit) async {
    if (state is TripsLoaded) {
      final currentState = state as TripsLoaded;
      if (currentState.isSearching && currentState.searchQuery != null) {
        add(SearchTrips(currentState.searchQuery!));
      } else {
        add(LoadAvailableTrips(filter: currentState.currentFilter));
      }
    } else {
      add(const LoadAvailableTrips());
    }
  }
}
