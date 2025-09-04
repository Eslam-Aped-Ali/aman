import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/shared/usecases/usecase_abstract.dart';
import '../../../domain/usecases/passenger_profile_usecases.dart';
import '../../../../../shared_fetaures/auth/domain/usecases/logout_usecase.dart';
import 'passenger_profile_state.dart';

class PassengerProfileCubit extends Cubit<PassengerProfileState> {
  final GetPassengerProfileUseCase getProfileUseCase;
  final UpdatePassengerProfileUseCase updateProfileUseCase;
  final UpdatePassengerPreferencesUseCase updatePreferencesUseCase;
  final LogoutUseCase logoutUseCase;

  PassengerProfileCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updatePreferencesUseCase,
    required this.logoutUseCase,
  }) : super(PassengerProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(PassengerProfileLoading());

    final result = await getProfileUseCase.call(userId);

    result.fold(
      (failure) => emit(PassengerProfileError(failure.message)),
      (profile) => emit(PassengerProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile(
      String userId, Map<String, dynamic> profileData) async {
    if (state is PassengerProfileLoaded) {
      final currentProfile = (state as PassengerProfileLoaded).profile;
      emit(PassengerProfileUpdating(currentProfile));

      final result = await updateProfileUseCase.call(
        UpdatePassengerProfileParams(
          userId: userId,
          profileData: profileData,
        ),
      );

      result.fold(
        (failure) => emit(PassengerProfileError(failure.message)),
        (profile) => emit(
            PassengerProfileUpdated(profile, 'Profile updated successfully')),
      );
    }
  }

  Future<void> updatePreferences(
      String userId, Map<String, bool> preferences) async {
    if (state is PassengerProfileLoaded) {
      final currentProfile = (state as PassengerProfileLoaded).profile;

      final result = await updatePreferencesUseCase.call(
        UpdatePreferencesParams(
          userId: userId,
          preferences: preferences,
        ),
      );

      result.fold(
        (failure) => emit(PassengerProfileError(failure.message)),
        (success) {
          if (success) {
            // Create updated profile with new preferences
            final updatedProfile = currentProfile.copyWith(
              preferenceNotifications: preferences['notifications'],
              preferenceLocationServices: preferences['location_services'],
              updatedAt: DateTime.now(),
            );
            emit(PassengerProfileUpdated(
                updatedProfile, 'Preferences updated successfully'));
          } else {
            emit(PassengerProfileError('Failed to update preferences'));
          }
        },
      );
    }
  }

  void resetToLoaded() {
    if (state is PassengerProfileUpdated) {
      final updatedState = state as PassengerProfileUpdated;
      emit(PassengerProfileLoaded(updatedState.profile));
    }
  }

  Future<void> logout() async {
    emit(PassengerProfileLoading());
    
    final result = await logoutUseCase(NoParams());
    
    result.fold(
      (failure) => emit(PassengerProfileError(failure.message)),
      (_) => emit(const PassengerProfileLoggedOut()),
    );
  }
}
