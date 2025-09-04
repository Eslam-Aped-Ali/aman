import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Aman/core/shared/usecases/usecase_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_driver_profile.dart';
import '../../domain/usecases/create_driver_profile.dart';
import '../../domain/usecases/update_driver_profile.dart';
import '../../domain/usecases/contact_admin.dart';
import 'driver_profile_event.dart';
import 'driver_profile_state.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final GetDriverProfileUseCase getDriverProfileUseCase;
  final CreateDriverProfileUseCase createDriverProfileUseCase;
  final UpdateDriverProfileUseCase updateDriverProfileUseCase;
  final ContactAdminUseCase contactAdminUseCase;
  final LogoutUseCase logoutUseCase;

  DriverProfileBloc({
    required this.getDriverProfileUseCase,
    required this.createDriverProfileUseCase,
    required this.updateDriverProfileUseCase,
    required this.contactAdminUseCase,
    required this.logoutUseCase,
  }) : super(DriverProfileInitial()) {
    on<LoadDriverProfile>(_onLoadDriverProfile);
    on<CreateDriverProfile>(_onCreateDriverProfile);
    on<UpdateDriverProfile>(_onUpdateDriverProfile);
    on<ContactAdmin>(_onContactAdmin);
    on<RefreshDriverProfile>(_onRefreshDriverProfile);
    on<LogoutDriver>(_onLogoutDriver);
  }

  Future<void> _onLoadDriverProfile(
    LoadDriverProfile event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(DriverProfileLoading());
    try {
      final profile = await getDriverProfileUseCase(event.driverId);
      if (profile != null) {
        emit(DriverProfileLoaded(profile));
      } else {
        emit(const DriverProfileNotFound());
      }
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }

  Future<void> _onCreateDriverProfile(
    CreateDriverProfile event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(DriverProfileLoading());
    try {
      final profile = await createDriverProfileUseCase(
        name: event.name,
        phoneNumber: event.phoneNumber,
        gender: event.gender,
        birthYear: event.birthYear,
      );
      emit(DriverProfileCreated(profile));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateDriverProfile(
    UpdateDriverProfile event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(DriverProfileLoading());
    try {
      final profile = await updateDriverProfileUseCase(event.profile);
      emit(DriverProfileUpdated(profile));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }

  Future<void> _onContactAdmin(
    ContactAdmin event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(ContactingAdmin());
    try {
      await contactAdminUseCase(event.phoneNumber);
      emit(ContactAdminSuccess());
    } catch (e) {
      emit(ContactAdminError(e.toString()));
    }
  }

  Future<void> _onRefreshDriverProfile(
    RefreshDriverProfile event,
    Emitter<DriverProfileState> emit,
  ) async {
    // Don't show loading for refresh
    try {
      final profile = await getDriverProfileUseCase(event.driverId);
      if (profile != null) {
        emit(DriverProfileLoaded(profile));
      } else {
        emit(const DriverProfileNotFound());
      }
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }

  Future<void> _onLogoutDriver(
    LogoutDriver event,
    Emitter<DriverProfileState> emit,
  ) async {
    try {
      final result = await logoutUseCase(NoParams());
      result.fold(
        (failure) => emit(DriverProfileError(failure.message)),
        (_) => emit(const DriverLoggedOut()),
      );
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }
}
