import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool tripUpdates;
  final bool promotionalOffers;
  final bool newFeatures;
  final bool securityAlerts;
  final bool dataCollection;
  final bool locationSharing;
  final bool analytics;
  final bool crashReports;
  final bool biometrics;
  final bool autoLogout;
  final int autoLogoutDuration; // in minutes
  final bool isLoading;
  final String? errorMessage;

  const SettingsState({
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.smsNotifications = false,
    this.tripUpdates = true,
    this.promotionalOffers = false,
    this.newFeatures = true,
    this.securityAlerts = true,
    this.dataCollection = true,
    this.locationSharing = true,
    this.analytics = false,
    this.crashReports = true,
    this.biometrics = false,
    this.autoLogout = false,
    this.autoLogoutDuration = 30,
    this.isLoading = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? tripUpdates,
    bool? promotionalOffers,
    bool? newFeatures,
    bool? securityAlerts,
    bool? dataCollection,
    bool? locationSharing,
    bool? analytics,
    bool? crashReports,
    bool? biometrics,
    bool? autoLogout,
    int? autoLogoutDuration,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      tripUpdates: tripUpdates ?? this.tripUpdates,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      newFeatures: newFeatures ?? this.newFeatures,
      securityAlerts: securityAlerts ?? this.securityAlerts,
      dataCollection: dataCollection ?? this.dataCollection,
      locationSharing: locationSharing ?? this.locationSharing,
      analytics: analytics ?? this.analytics,
      crashReports: crashReports ?? this.crashReports,
      biometrics: biometrics ?? this.biometrics,
      autoLogout: autoLogout ?? this.autoLogout,
      autoLogoutDuration: autoLogoutDuration ?? this.autoLogoutDuration,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        pushNotifications,
        emailNotifications,
        smsNotifications,
        tripUpdates,
        promotionalOffers,
        newFeatures,
        securityAlerts,
        dataCollection,
        locationSharing,
        analytics,
        crashReports,
        biometrics,
        autoLogout,
        autoLogoutDuration,
        isLoading,
        errorMessage,
      ];
}
