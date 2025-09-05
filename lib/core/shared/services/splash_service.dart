// lib/core/shared/services/splash_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashService {
  static bool _initialized = false;

  /// Initialize the splash service and preserve the native splash
  static void preserve() {
    if (!_initialized) {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      _initialized = true;
    }
  }

  /// Remove the native splash screen
  static void remove() {
    if (_initialized) {
      FlutterNativeSplash.remove();
    }
  }

  /// Remove the native splash after a delay
  static Future<void> removeAfterDelay(Duration delay) async {
    await Future.delayed(delay);
    remove();
  }

  /// Check if the device supports splash screen removal
  static Future<bool> get canControlSplash async {
    try {
      // Try to access platform channel to see if it's available
      await const MethodChannel('flutter_native_splash').invokeMethod('getOS');
      return true;
    } catch (e) {
      return false;
    }
  }
}
