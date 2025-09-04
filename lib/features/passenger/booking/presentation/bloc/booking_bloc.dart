import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/booking_request_model.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_popular_locations.dart';
import '../../domain/usecases/search_locations.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetPopularLocationsUseCase getPopularLocationsUseCase;
  final SearchLocationsUseCase searchLocationsUseCase;
  final CreateBookingUseCase createBookingUseCase;
  final GetCurrentLocationUseCase getCurrentLocationUseCase;

  BookingBloc({
    required this.getPopularLocationsUseCase,
    required this.searchLocationsUseCase,
    required this.createBookingUseCase,
    required this.getCurrentLocationUseCase,
  }) : super(const BookingInitial()) {
    on<LoadPopularLocations>(_onLoadPopularLocations);
    on<SearchLocations>(_onSearchLocations);
    on<SelectPickupLocation>(_onSelectPickupLocation);
    on<SelectDropoffLocation>(_onSelectDropoffLocation);
    on<CreateBooking>(_onCreateBooking);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<ClearSelectedLocations>(_onClearSelectedLocations);
  }

  Future<void> _onLoadPopularLocations(
      LoadPopularLocations event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());

    final result = await getPopularLocationsUseCase();

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (locations) => emit(LocationsLoaded(locations: locations)),
    );
  }

  Future<void> _onSearchLocations(
      SearchLocations event, Emitter<BookingState> emit) async {
    if (state is LocationsLoaded) {
      final currentState = state as LocationsLoaded;
      emit(currentState.copyWith(isSearching: true));
    } else {
      emit(const BookingLoading());
    }

    final result = await searchLocationsUseCase(event.query);

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (locations) {
        if (state is LocationsLoaded) {
          final currentState = state as LocationsLoaded;
          emit(currentState.copyWith(
            locations: locations,
            isSearching: false,
          ));
        } else {
          emit(LocationsLoaded(
            locations: locations,
            isSearching: false,
          ));
        }
      },
    );
  }

  void _onSelectPickupLocation(
      SelectPickupLocation event, Emitter<BookingState> emit) {
    if (state is LocationsLoaded) {
      final currentState = state as LocationsLoaded;
      emit(currentState.copyWith(
        selectedPickupLocation: event.location,
      ));
    } else {
      emit(LocationsLoaded(
        locations: const [],
        selectedPickupLocation: event.location,
      ));
    }
  }

  void _onSelectDropoffLocation(
      SelectDropoffLocation event, Emitter<BookingState> emit) {
    if (state is LocationsLoaded) {
      final currentState = state as LocationsLoaded;
      emit(currentState.copyWith(
        selectedDropoffLocation: event.location,
      ));
    } else {
      emit(LocationsLoaded(
        locations: const [],
        selectedDropoffLocation: event.location,
      ));
    }
  }

  Future<void> _onCreateBooking(
      CreateBooking event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());

    // Create booking request model
    final booking = BookingRequestModel(
      id: '', // Will be generated in data source
      trip: event.trip,
      pickupLocation: event.pickupLocation,
      dropoffLocation: event.dropoffLocation,
      bookingDate: event.trip.departureTime,
      requestedDate: DateTime.now(),
      passengerName: event.passengerName,
      passengerPhone: event.passengerPhone,
      passengerEmail: event.passengerEmail,
      specialInstructions: event.specialInstructions,
      status: BookingStatus.pending,
      totalAmount: event.trip.finalPrice,
      extraCharges: 0.0,
      paymentMethod: event.paymentMethod,
      requiresSpecialAssistance: event.requiresSpecialAssistance,
      numberOfPassengers: event.numberOfPassengers,
      createdAt: DateTime.now(),
    );

    final result = await createBookingUseCase(booking);

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (createdBooking) => emit(BookingCreated(createdBooking)),
    );
  }

  Future<void> _onGetCurrentLocation(
      GetCurrentLocation event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());

    final result = await getCurrentLocationUseCase();

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (location) => emit(CurrentLocationLoaded(location)),
    );
  }

  void _onClearSelectedLocations(
      ClearSelectedLocations event, Emitter<BookingState> emit) {
    if (state is LocationsLoaded) {
      final currentState = state as LocationsLoaded;
      emit(currentState.copyWith(
        selectedPickupLocation: null,
        selectedDropoffLocation: null,
      ));
    }
  }
}
