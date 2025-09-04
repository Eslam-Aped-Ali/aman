import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_trip.dart';
import '../../domain/usecases/get_my_bookings.dart';
import '../../domain/usecases/cancel_trip.dart';
import '../../domain/usecases/get_trip_updates.dart';
import 'live_tracking_event.dart';
import 'live_tracking_state.dart';

class LiveTrackingBloc extends Bloc<LiveTrackingEvent, LiveTrackingState> {
  final GetCurrentTripUseCase getCurrentTripUseCase;
  final GetMyBookingsUseCase getMyBookingsUseCase;
  final CancelTripUseCase cancelTripUseCase;
  final GetTripUpdatesUseCase getTripUpdatesUseCase;

  StreamSubscription? _tripUpdatesSubscription;

  LiveTrackingBloc({
    required this.getCurrentTripUseCase,
    required this.getMyBookingsUseCase,
    required this.cancelTripUseCase,
    required this.getTripUpdatesUseCase,
  }) : super(LiveTrackingInitial()) {
    on<LoadCurrentTrip>(_onLoadCurrentTrip);
    on<LoadMyBookings>(_onLoadMyBookings);
    on<CancelTrip>(_onCancelTrip);
    on<ContactDriver>(_onContactDriver);
    on<StartTripTracking>(_onStartTripTracking);
    on<StopTripTracking>(_onStopTripTracking);
    on<RateDriver>(_onRateDriver);
    on<ReportIssue>(_onReportIssue);
    on<LoadTripRoute>(_onLoadTripRoute);
    on<RefreshCurrentTrip>(_onRefreshCurrentTrip);
    on<SelectBookingForTracking>(_onSelectBookingForTracking);
  }

  Future<void> _onLoadCurrentTrip(
    LoadCurrentTrip event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(LiveTrackingLoading());

    final result = await getCurrentTripUseCase(event.passengerId);

    result.fold(
      (failure) => emit(LiveTrackingError(failure.message)),
      (trip) => emit(CurrentTripLoaded(trip)),
    );
  }

  Future<void> _onLoadMyBookings(
    LoadMyBookings event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(LiveTrackingLoading());

    final bookingsResult = await getMyBookingsUseCase(event.passengerId);

    bookingsResult.fold(
      (failure) => emit(LiveTrackingError(failure.message)),
      (bookings) async {
        // Also get current trip
        final currentTripResult =
            await getCurrentTripUseCase(event.passengerId);
        currentTripResult.fold(
          (failure) => emit(MyBookingsLoaded(bookings)),
          (currentTrip) => emit(MyBookingsLoaded(bookings, currentTrip)),
        );
      },
    );
  }

  Future<void> _onCancelTrip(
    CancelTrip event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(LiveTrackingLoading());

    final result = await cancelTripUseCase(event.tripId);

    result.fold(
      (failure) => emit(LiveTrackingError(failure.message)),
      (success) {
        if (success) {
          emit(TripCancelled(event.tripId));
        } else {
          emit(const LiveTrackingError('Failed to cancel trip'));
        }
      },
    );
  }

  Future<void> _onContactDriver(
    ContactDriver event,
    Emitter<LiveTrackingState> emit,
  ) async {
    // For now, just emit success. In real app, this would use a contact driver use case
    await Future.delayed(const Duration(milliseconds: 500));
    emit(DriverContacted(event.driverId));
  }

  Future<void> _onStartTripTracking(
    StartTripTracking event,
    Emitter<LiveTrackingState> emit,
  ) async {
    // Cancel any existing subscription
    await _tripUpdatesSubscription?.cancel();

    final updatesStream = getTripUpdatesUseCase(event.tripId);

    _tripUpdatesSubscription = updatesStream.listen(
      (result) {
        result.fold(
          (failure) => emit(LiveTrackingError(failure.message)),
          (trip) => emit(TripTrackingActive(trip)),
        );
      },
      onError: (error) {
        emit(LiveTrackingError('Lost connection to trip updates'));
      },
    );
  }

  Future<void> _onStopTripTracking(
    StopTripTracking event,
    Emitter<LiveTrackingState> emit,
  ) async {
    await _tripUpdatesSubscription?.cancel();
    _tripUpdatesSubscription = null;
    emit(LiveTrackingInitial());
  }

  Future<void> _onRateDriver(
    RateDriver event,
    Emitter<LiveTrackingState> emit,
  ) async {
    // For now, just emit success. In real app, this would use a rate driver use case
    await Future.delayed(const Duration(milliseconds: 800));
    emit(DriverRated(event.tripId, event.rating));
  }

  Future<void> _onReportIssue(
    ReportIssue event,
    Emitter<LiveTrackingState> emit,
  ) async {
    // For now, just emit success. In real app, this would use a report issue use case
    await Future.delayed(const Duration(milliseconds: 600));
    emit(IssueReported(event.tripId, event.issue));
  }

  Future<void> _onLoadTripRoute(
    LoadTripRoute event,
    Emitter<LiveTrackingState> emit,
  ) async {
    // For now, just emit empty route. In real app, this would use a get trip route use case
    await Future.delayed(const Duration(milliseconds: 400));
    emit(const TripRouteLoaded([]));
  }

  Future<void> _onRefreshCurrentTrip(
    RefreshCurrentTrip event,
    Emitter<LiveTrackingState> emit,
  ) async {
    final result = await getCurrentTripUseCase(event.passengerId);

    result.fold(
      (failure) => emit(LiveTrackingError(failure.message)),
      (trip) => emit(CurrentTripLoaded(trip)),
    );
  }

  Future<void> _onSelectBookingForTracking(
    SelectBookingForTracking event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (event.trip.isActive) {
      emit(TripTrackingActive(event.trip));
      // Start real-time tracking
      add(StartTripTracking(event.trip.id));
    } else {
      emit(CurrentTripLoaded(event.trip));
    }
  }

  @override
  Future<void> close() {
    _tripUpdatesSubscription?.cancel();
    return super.close();
  }
}
