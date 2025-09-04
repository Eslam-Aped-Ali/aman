import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../app_theme.dart';

enum AppThemeMode { light, dark, system, colorBlind }

extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.colorBlind:
        return 'Color Blind';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.auto_mode;
      case AppThemeMode.colorBlind:
        return Icons.accessibility;
    }
  }
}

class ThemeState extends Equatable {
  final AppThemeMode themeMode;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
  });

  // Add this getter
  ThemeMode get materialThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
      case AppThemeMode.colorBlind:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Add this getter to check if colorblind mode is active
  bool get isColorBlindMode => themeMode == AppThemeMode.colorBlind;

  ThemeData get lightTheme => AppTheme.lightTheme();

  ThemeData get darkTheme => AppTheme.darkTheme();

  ThemeData get colorblindTheme => AppTheme.colorblindTheme();

  ThemeState copyWith({
    AppThemeMode? themeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [themeMode];
}
