import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  arabic,
  system;

  String get languageCode {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.system:
        return 'system'; // Will be handled differently
    }
  }

  String get countryCode {
    switch (this) {
      case AppLanguage.english:
        return 'US';
      case AppLanguage.arabic:
        return 'SA';
      case AppLanguage.system:
        return 'US'; // Default fallback
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.english:
        return const Locale('en', 'US');
      case AppLanguage.arabic:
        return const Locale('ar', 'SA');
      case AppLanguage.system:
        return const Locale('en', 'US'); // Default fallback
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.arabic:
        return 'العربية';
      case AppLanguage.system:
        return 'Auto Detect';
    }
  }

  IconData get icon {
    switch (this) {
      case AppLanguage.english:
        return Icons.language;
      case AppLanguage.arabic:
        return Icons.language;
      case AppLanguage.system:
        return Icons.auto_mode;
    }
  }
}

class LanguageState extends Equatable {
  final AppLanguage selectedLanguage;
  final bool isLoading;
  final String? errorMessage;

  const LanguageState({
    this.selectedLanguage = AppLanguage.system,
    this.isLoading = false,
    this.errorMessage,
  });

  LanguageState copyWith({
    AppLanguage? selectedLanguage,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LanguageState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [selectedLanguage, isLoading, errorMessage];
}
