import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_trips.dart';
import '../../domain/usecases/get_trip_history.dart';
import '../../domain/usecases/get_trip_passengers.dart';
import '../../domain/usecases/update_passenger_status.dart';
import '../../domain/usecases/notify_passenger_arrival.dart';
import '../../domain/usecases/start_trip.dart';
import '../../domain/usecases/complete_trip.dart';
import 'driver_trips_event.dart';
import 'driver_trips_state.dart';

class DriverTripsBloc extends Bloc<DriverTripsEvent, DriverTripsState> {
  final GetCurrentTripsUseCase getCurrentTripsUseCase;
  final GetTripHistoryUseCase getTripHistoryUseCase;
  final GetTripPassengersUseCase getTripPassengersUseCase;
  final UpdatePassengerStatusUseCase updatePassengerStatusUseCase;
  final NotifyPassengerArrivalUseCase notifyPassengerArrivalUseCase;
  final StartTripUseCase startTripUseCase;
  final CompleteTripUseCase completeTripUseCase;

  DriverTripsBloc({
    required this.getCurrentTripsUseCase,
    required this.getTripHistoryUseCase,
    required this.getTripPassengersUseCase,
    required this.updatePassengerStatusUseCase,
    required this.notifyPassengerArrivalUseCase,
    required this.startTripUseCase,
    required this.completeTripUseCase,
  }) : super(DriverTripsInitial()) {
    on<LoadCurrentTrips>(_onLoadCurrentTrips);
    on<LoadTripHistory>(_onLoadTripHistory);
    on<LoadTripPassengers>(_onLoadTripPassengers);
    on<UpdatePassengerStatus>(_onUpdatePassengerStatus);
    on<NotifyPassengerArrival>(_onNotifyPassengerArrival);
    on<StartTrip>(_onStartTrip);
    on<CompleteTrip>(_onCompleteTrip);
    on<RefreshCurrentTrips>(_onRefreshCurrentTrips);
  }

  Future<void> _onLoadCurrentTrips(
    LoadCurrentTrips event,
    Emitter<DriverTripsState> emit,
  ) async {
    emit(DriverTripsLoading());
    try {
      final trips = await getCurrentTripsUseCase(event.driverId);
      if (trips.isEmpty) {
        emit(const DriverTripsEmpty('No current trips assigned'));
      } else {
        emit(CurrentTripsLoaded(trips));
      }
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  Future<void> _onLoadTripHistory(
    LoadTripHistory event,
    Emitter<DriverTripsState> emit,
  ) async {
    emit(DriverTripsLoading());
    try {
      final trips = await getTripHistoryUseCase(event.driverId);
      if (trips.isEmpty) {
        emit(const DriverTripsEmpty('No trip history found'));
      } else {
        emit(TripHistoryLoaded(trips));
      }
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  Future<void> _onLoadTripPassengers(
    LoadTripPassengers event,
    Emitter<DriverTripsState> emit,
  ) async {
    emit(DriverTripsLoading());
    try {
      final passengers = await getTripPassengersUseCase(event.tripId);
      emit(TripPassengersLoaded(
        passengers: passengers,
        tripId: event.tripId,
      ));
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  Future<void> _onUpdatePassengerStatus(
    UpdatePassengerStatus event,
    Emitter<DriverTripsState> emit,
  ) async {
    try {
      final updatedPassenger = await updatePassengerStatusUseCase(
        event.tripId,
        event.passengerId,
        event.status,
      );
      emit(PassengerStatusUpdated(updatedPassenger));

      // Reload passengers to show updated state
      final passengers = await getTripPassengersUseCase(event.tripId);
      emit(TripPassengersLoaded(
        passengers: passengers,
        tripId: event.tripId,
      ));
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  Future<void> _onNotifyPassengerArrival(
    NotifyPassengerArrival event,
    Emitter<DriverTripsState> emit,
  ) async {
    try {
      await notifyPassengerArrivalUseCase(event.passengerId, event.message);
      emit(PassengerNotified('Passenger notified successfully'));
    } catch (e) {
      emit(DriverTripsError('Failed to notify passenger: ${e.toString()}'));
    }
  }

  Future<void> _onStartTrip(
    StartTrip event,
    Emitter<DriverTripsState> emit,
  ) async {
    try {
      final trip = await startTripUseCase(event.tripId);
      emit(TripStarted(trip));
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  Future<void> _onCompleteTrip(
    CompleteTrip event,
    Emitter<DriverTripsState> emit,
  ) async {
    try {
      final trip = await completeTripUseCase(event.tripId);
      emit(TripCompleted(trip));
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  Future<void> _onRefreshCurrentTrips(
    RefreshCurrentTrips event,
    Emitter<DriverTripsState> emit,
  ) async {
    // Don't show loading for refresh
    try {
      final trips = await getCurrentTripsUseCase(event.driverId);
      if (trips.isEmpty) {
        emit(const DriverTripsEmpty('No current trips assigned'));
      } else {
        emit(CurrentTripsLoaded(trips));
      }
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }
}
