import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_trips.dart';
import '../../domain/usecases/get_trip_history.dart';
import '../../domain/usecases/get_trip_passengers.dart';
import '../../domain/usecases/update_passenger_status.dart';
import '../../domain/usecases/notify_passenger_arrival.dart';
import '../../domain/usecases/start_trip.dart';
import '../../domain/usecases/complete_trip.dart';
import '../../domain/usecases/get_trips_by_status.dart';
import '../../domain/usecases/update_trip_status.dart';
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
  final GetTripsByStatusUseCase getTripsByStatusUseCase;
  final UpdateTripStatusUseCase updateTripStatusUseCase;

  DriverTripsBloc({
    required this.getCurrentTripsUseCase,
    required this.getTripHistoryUseCase,
    required this.getTripPassengersUseCase,
    required this.updatePassengerStatusUseCase,
    required this.notifyPassengerArrivalUseCase,
    required this.startTripUseCase,
    required this.completeTripUseCase,
    required this.getTripsByStatusUseCase,
    required this.updateTripStatusUseCase,
  }) : super(DriverTripsInitial()) {
    on<LoadCurrentTrips>(_onLoadCurrentTrips);
    on<LoadTripsByStatus>(_onLoadTripsByStatus);
    on<LoadTripHistory>(_onLoadTripHistory);
    on<LoadTripPassengers>(_onLoadTripPassengers);
    on<UpdatePassengerStatus>(_onUpdatePassengerStatus);
    on<NotifyPassengerArrival>(_onNotifyPassengerArrival);
    on<StartTrip>(_onStartTrip);
    on<CompleteTrip>(_onCompleteTrip);
    on<UpdateTripStatus>(_onUpdateTripStatus);
    on<RefreshCurrentTrips>(_onRefreshCurrentTrips);
  }

  Future<void> _onLoadCurrentTrips(
    LoadCurrentTrips event,
    Emitter<DriverTripsState> emit,
  ) async {
    emit(DriverTripsLoading());
    try {
      // Load both SCHEDULED and STARTED trips for current trips
      final scheduledParams = GetTripsByStatusParams(
        driverId: event.driverId,
        status: 'SCHEDULED',
      );
      final startedParams = GetTripsByStatusParams(
        driverId: event.driverId,
        status: 'STARTED',
      );

      final scheduledTrips = await getTripsByStatusUseCase(scheduledParams);
      final startedTrips = await getTripsByStatusUseCase(startedParams);

      final allCurrentTrips = [...scheduledTrips, ...startedTrips];

      if (allCurrentTrips.isEmpty) {
        emit(const DriverTripsEmpty('No current trips assigned'));
      } else {
        emit(CurrentTripsLoaded(allCurrentTrips));
      }
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  Future<void> _onLoadTripsByStatus(
    LoadTripsByStatus event,
    Emitter<DriverTripsState> emit,
  ) async {
    emit(DriverTripsLoading());
    try {
      final params = GetTripsByStatusParams(
        driverId: event.driverId,
        status: event.status,
      );
      final trips = await getTripsByStatusUseCase(params);

      if (trips.isEmpty) {
        emit(DriverTripsEmpty('No ${event.status.toLowerCase()} trips found'));
      } else {
        // Emit different states based on status
        switch (event.status.toUpperCase()) {
          case 'COMPLETED':
          case 'CANCELLED':
            emit(TripHistoryLoaded(trips));
            break;
          case 'SCHEDULED':
          case 'STARTED':
          default:
            emit(CurrentTripsLoaded(trips));
            break;
        }
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
      // Use API to load completed trips
      final params = GetTripsByStatusParams(
        driverId: event.driverId,
        status: 'COMPLETED',
      );
      final trips = await getTripsByStatusUseCase(params);
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

  Future<void> _onUpdateTripStatus(
    UpdateTripStatus event,
    Emitter<DriverTripsState> emit,
  ) async {
    try {
      final params = UpdateTripStatusParams(
        tripId: event.tripId,
        status: event.status,
      );
      final trip = await updateTripStatusUseCase(params);

      // Emit appropriate state based on status
      switch (event.status.toUpperCase()) {
        case 'STARTED':
          emit(TripStarted(trip));
          break;
        case 'COMPLETED':
          emit(TripCompleted(trip));
          break;
        default:
          emit(TripStatusUpdated(trip, event.status));
      }
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }

  Future<void> _onRefreshCurrentTrips(
    RefreshCurrentTrips event,
    Emitter<DriverTripsState> emit,
  ) async {
    // Don't show loading for refresh - load current trips (SCHEDULED + STARTED)
    try {
      final scheduledParams = GetTripsByStatusParams(
        driverId: event.driverId,
        status: 'SCHEDULED',
      );
      final startedParams = GetTripsByStatusParams(
        driverId: event.driverId,
        status: 'STARTED',
      );

      final scheduledTrips = await getTripsByStatusUseCase(scheduledParams);
      final startedTrips = await getTripsByStatusUseCase(startedParams);

      final allCurrentTrips = [...scheduledTrips, ...startedTrips];

      if (allCurrentTrips.isEmpty) {
        emit(const DriverTripsEmpty('No current trips assigned'));
      } else {
        emit(CurrentTripsLoaded(allCurrentTrips));
      }
    } catch (e) {
      emit(DriverTripsError(e.toString()));
    }
  }
}
