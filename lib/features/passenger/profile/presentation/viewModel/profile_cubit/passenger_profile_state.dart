import 'package:equatable/equatable.dart';

import '../../../domain/entities/passenger_profile.dart';

abstract class PassengerProfileState extends Equatable {
  const PassengerProfileState();

  @override
  List<Object?> get props => [];
}

class PassengerProfileInitial extends PassengerProfileState {}

class PassengerProfileLoading extends PassengerProfileState {}

class PassengerProfileLoaded extends PassengerProfileState {
  final PassengerProfile profile;

  const PassengerProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class PassengerProfileError extends PassengerProfileState {
  final String message;

  const PassengerProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class PassengerProfileUpdating extends PassengerProfileState {
  final PassengerProfile profile;

  const PassengerProfileUpdating(this.profile);

  @override
  List<Object> get props => [profile];
}

class PassengerProfileUpdated extends PassengerProfileState {
  final PassengerProfile profile;
  final String message;

  const PassengerProfileUpdated(this.profile, this.message);

  @override
  List<Object> get props => [profile, message];
}

class PassengerProfileLoggedOut extends PassengerProfileState {
  const PassengerProfileLoggedOut();
}
