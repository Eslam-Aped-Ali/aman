import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_profile.dart';

abstract class DriverProfileEvent extends Equatable {
  const DriverProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadDriverProfile extends DriverProfileEvent {
  final String driverId;

  const LoadDriverProfile(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class CreateDriverProfile extends DriverProfileEvent {
  final String name;
  final String phoneNumber;
  final Gender gender;
  final int birthYear;

  const CreateDriverProfile({
    required this.name,
    required this.phoneNumber,
    required this.gender,
    required this.birthYear,
  });

  @override
  List<Object?> get props => [name, phoneNumber, gender, birthYear];
}

class UpdateDriverProfile extends DriverProfileEvent {
  final DriverProfile profile;

  const UpdateDriverProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ContactAdmin extends DriverProfileEvent {
  final String phoneNumber;

  const ContactAdmin(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class RefreshDriverProfile extends DriverProfileEvent {
  final String driverId;

  const RefreshDriverProfile(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class LogoutDriver extends DriverProfileEvent {
  const LogoutDriver();
}
