import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_profile.dart';

abstract class DriverProfileState extends Equatable {
  const DriverProfileState();

  @override
  List<Object?> get props => [];
}

class DriverProfileInitial extends DriverProfileState {}

class DriverProfileLoading extends DriverProfileState {}

class DriverProfileNotFound extends DriverProfileState {
  final String message;

  const DriverProfileNotFound([this.message = 'Driver profile not found']);

  @override
  List<Object?> get props => [message];
}

class DriverProfileLoaded extends DriverProfileState {
  final DriverProfile profile;

  const DriverProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DriverProfileCreated extends DriverProfileState {
  final DriverProfile profile;

  const DriverProfileCreated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DriverProfileUpdated extends DriverProfileState {
  final DriverProfile profile;

  const DriverProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DriverProfileError extends DriverProfileState {
  final String message;

  const DriverProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ContactingAdmin extends DriverProfileState {}

class ContactAdminSuccess extends DriverProfileState {}

class ContactAdminError extends DriverProfileState {
  final String message;

  const ContactAdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverLoggedOut extends DriverProfileState {
  const DriverLoggedOut();
}
