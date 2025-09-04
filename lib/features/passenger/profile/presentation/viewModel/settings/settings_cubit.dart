import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../core/shared/services/firebase_service.dart';
import '../../../../../../core/shared/utils/depugging/debug_utils.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  // Storage keys
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _smsNotificationsKey = 'sms_notifications';
  static const String _tripUpdatesKey = 'trip_updates';
  static const String _promotionalOffersKey = 'promotional_offers';
  static const String _newFeaturesKey = 'new_features';
  static const String _securityAlertsKey = 'security_alerts';
  static const String _dataCollectionKey = 'data_collection';
  static const String _locationSharingKey = 'location_sharing';
  static const String _analyticsKey = 'analytics';
  static const String _crashReportsKey = 'crash_reports';
  static const String _biometricsKey = 'biometrics';
  static const String _autoLogoutKey = 'auto_logout';
  static const String _autoLogoutDurationKey = 'auto_logout_duration';

  /// Load all settings from storage
  Future<void> loadSettings() async {
    try {
      emit(state.copyWith(isLoading: true));

      await StorageService.init();

      final settings = SettingsState(
        pushNotifications:
            StorageService.getBool(_pushNotificationsKey) ?? true,
        emailNotifications:
            StorageService.getBool(_emailNotificationsKey) ?? false,
        smsNotifications: StorageService.getBool(_smsNotificationsKey) ?? false,
        tripUpdates: StorageService.getBool(_tripUpdatesKey) ?? true,
        promotionalOffers:
            StorageService.getBool(_promotionalOffersKey) ?? false,
        newFeatures: StorageService.getBool(_newFeaturesKey) ?? true,
        securityAlerts: StorageService.getBool(_securityAlertsKey) ?? true,
        dataCollection: StorageService.getBool(_dataCollectionKey) ?? true,
        locationSharing: StorageService.getBool(_locationSharingKey) ?? true,
        analytics: StorageService.getBool(_analyticsKey) ?? false,
        crashReports: StorageService.getBool(_crashReportsKey) ?? true,
        biometrics: StorageService.getBool(_biometricsKey) ?? false,
        autoLogout: StorageService.getBool(_autoLogoutKey) ?? false,
        autoLogoutDuration: StorageService.getInt(_autoLogoutDurationKey) ?? 30,
        isLoading: false,
      );

      emit(settings);
      Console.printSuccess('Settings loaded successfully');
    } catch (e) {
      Console.printError('Failed to load settings: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load settings',
      ));
    }
  }

  /// Update push notifications setting
  Future<void> updatePushNotifications(bool value) async {
    try {
      await StorageService.setBool(_pushNotificationsKey, value);
      emit(state.copyWith(pushNotifications: value));

      // // Update Firebase Analytics
      // FirebaseService.instance.setUserProperty(
      //   name: 'push_notifications',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Push notifications: $value');
    } catch (e) {
      Console.printError('Failed to update push notifications: $e');
    }
  }

  /// Update email notifications setting
  Future<void> updateEmailNotifications(bool value) async {
    try {
      await StorageService.setBool(_emailNotificationsKey, value);
      emit(state.copyWith(emailNotifications: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'email_notifications',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Email notifications: $value');
    } catch (e) {
      Console.printError('Failed to update email notifications: $e');
    }
  }

  /// Update SMS notifications setting
  Future<void> updateSmsNotifications(bool value) async {
    try {
      await StorageService.setBool(_smsNotificationsKey, value);
      emit(state.copyWith(smsNotifications: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'sms_notifications',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('SMS notifications: $value');
    } catch (e) {
      Console.printError('Failed to update SMS notifications: $e');
    }
  }

  /// Update trip updates setting
  Future<void> updateTripUpdates(bool value) async {
    try {
      await StorageService.setBool(_tripUpdatesKey, value);
      emit(state.copyWith(tripUpdates: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'trip_updates',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Trip updates: $value');
    } catch (e) {
      Console.printError('Failed to update trip updates: $e');
    }
  }

  /// Update promotional offers setting
  Future<void> updatePromotionalOffers(bool value) async {
    try {
      await StorageService.setBool(_promotionalOffersKey, value);
      emit(state.copyWith(promotionalOffers: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'promotional_offers',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Promotional offers: $value');
    } catch (e) {
      Console.printError('Failed to update promotional offers: $e');
    }
  }

  /// Update new features setting
  Future<void> updateNewFeatures(bool value) async {
    try {
      await StorageService.setBool(_newFeaturesKey, value);
      emit(state.copyWith(newFeatures: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'new_features',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('New features: $value');
    } catch (e) {
      Console.printError('Failed to update new features: $e');
    }
  }

  /// Update security alerts setting
  Future<void> updateSecurityAlerts(bool value) async {
    try {
      await StorageService.setBool(_securityAlertsKey, value);
      emit(state.copyWith(securityAlerts: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'security_alerts',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Security alerts: $value');
    } catch (e) {
      Console.printError('Failed to update security alerts: $e');
    }
  }

  /// Update data collection setting
  Future<void> updateDataCollection(bool value) async {
    try {
      await StorageService.setBool(_dataCollectionKey, value);
      emit(state.copyWith(dataCollection: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'data_collection',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Data collection: $value');
    } catch (e) {
      Console.printError('Failed to update data collection: $e');
    }
  }

  /// Update location sharing setting
  Future<void> updateLocationSharing(bool value) async {
    try {
      await StorageService.setBool(_locationSharingKey, value);
      emit(state.copyWith(locationSharing: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'location_sharing',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Location sharing: $value');
    } catch (e) {
      Console.printError('Failed to update location sharing: $e');
    }
  }

  /// Update analytics setting
  Future<void> updateAnalytics(bool value) async {
    try {
      await StorageService.setBool(_analyticsKey, value);
      emit(state.copyWith(analytics: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'analytics',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Analytics: $value');
    } catch (e) {
      Console.printError('Failed to update analytics: $e');
    }
  }

  /// Update crash reports setting
  Future<void> updateCrashReports(bool value) async {
    try {
      await StorageService.setBool(_crashReportsKey, value);
      emit(state.copyWith(crashReports: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'crash_reports',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Crash reports: $value');
    } catch (e) {
      Console.printError('Failed to update crash reports: $e');
    }
  }

  /// Update biometrics setting
  Future<void> updateBiometrics(bool value) async {
    try {
      await StorageService.setBool(_biometricsKey, value);
      emit(state.copyWith(biometrics: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'biometrics',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Biometrics: $value');
    } catch (e) {
      Console.printError('Failed to update biometrics: $e');
    }
  }

  /// Update auto logout setting
  Future<void> updateAutoLogout(bool value) async {
    try {
      await StorageService.setBool(_autoLogoutKey, value);
      emit(state.copyWith(autoLogout: value));

      // FirebaseService.instance.setUserProperty(
      //   name: 'auto_logout',
      //   value: value.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Auto logout: $value');
    } catch (e) {
      Console.printError('Failed to update auto logout: $e');
    }
  }

  /// Update auto logout duration
  Future<void> updateAutoLogoutDuration(int minutes) async {
    try {
      await StorageService.setInt(_autoLogoutDurationKey, minutes);
      emit(state.copyWith(autoLogoutDuration: minutes));

      // FirebaseService.instance.setUserProperty(
      //   name: 'auto_logout_duration',
      //   value: minutes.toString(),
      // );

      HapticFeedback.selectionClick();
      Console.printInfo('Auto logout duration: $minutes minutes');
    } catch (e) {
      Console.printError('Failed to update auto logout duration: $e');
    }
  }

  /// Clear all cache and temporary data
  Future<void> clearCache() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Clear cache (implement based on your caching strategy)
      // This is a placeholder - implement according to your app's cache system
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(isLoading: false));
      Console.printSuccess('Cache cleared successfully');
    } catch (e) {
      Console.printError('Failed to clear cache: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to clear cache',
      ));
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      emit(state.copyWith(isLoading: true));

      const defaultSettings = SettingsState();

      // Save defaults to storage
      await StorageService.setBool(
          _pushNotificationsKey, defaultSettings.pushNotifications);
      await StorageService.setBool(
          _emailNotificationsKey, defaultSettings.emailNotifications);
      await StorageService.setBool(
          _smsNotificationsKey, defaultSettings.smsNotifications);
      await StorageService.setBool(
          _tripUpdatesKey, defaultSettings.tripUpdates);
      await StorageService.setBool(
          _promotionalOffersKey, defaultSettings.promotionalOffers);
      await StorageService.setBool(
          _newFeaturesKey, defaultSettings.newFeatures);
      await StorageService.setBool(
          _securityAlertsKey, defaultSettings.securityAlerts);
      await StorageService.setBool(
          _dataCollectionKey, defaultSettings.dataCollection);
      await StorageService.setBool(
          _locationSharingKey, defaultSettings.locationSharing);
      await StorageService.setBool(_analyticsKey, defaultSettings.analytics);
      await StorageService.setBool(
          _crashReportsKey, defaultSettings.crashReports);
      await StorageService.setBool(_biometricsKey, defaultSettings.biometrics);
      await StorageService.setBool(_autoLogoutKey, defaultSettings.autoLogout);
      await StorageService.setInt(
          _autoLogoutDurationKey, defaultSettings.autoLogoutDuration);

      emit(defaultSettings);
      Console.printSuccess('Settings reset to defaults');
      HapticFeedback.mediumImpact();
    } catch (e) {
      Console.printError('Failed to reset settings: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to reset settings',
      ));
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
