import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../core/shared/services/firebase_service.dart';
import '../../../../../../core/shared/utils/depugging/debug_utils.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(const LanguageState());

  static const String _languageKey = 'app_language';

  /// Load saved language preference
  Future<void> loadLanguage() async {
    try {
      emit(state.copyWith(isLoading: true));

      await StorageService.init();
      final languageIndex =
          StorageService.getInt(_languageKey) ?? AppLanguage.system.index;
      final language = AppLanguage.values[languageIndex];

      emit(state.copyWith(
        selectedLanguage: language,
        isLoading: false,
      ));

      Console.printSuccess('Language loaded: ${language.displayName}');
    } catch (e) {
      Console.printError('Failed to load language: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load language preference',
      ));
    }
  }

  /// Change app language
  Future<void> changeLanguage(
      AppLanguage language, BuildContext context) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Save language preference
      await StorageService.setInt(_languageKey, language.index);

      // Apply language change using EasyLocalization immediately
      if (language != AppLanguage.system) {
        // Check if the exact locale is supported, otherwise fall back to language code only
        final targetLocale = language.locale;
        final supportedLocales = context.supportedLocales;

        Locale localeToUse = targetLocale;
        if (!supportedLocales.contains(targetLocale)) {
          // Try to find a supported locale with the same language code
          final fallbackLocale = supportedLocales.firstWhere(
            (locale) => locale.languageCode == targetLocale.languageCode,
            orElse: () => Locale(targetLocale.languageCode),
          );
          localeToUse = fallbackLocale;
        }

        await context.setLocale(localeToUse);
      } else {
        // Use system locale
        await context.resetLocale();
      }

      // // Update Firebase Analytics
      // FirebaseService.instance.setUserProperty(
      //   name: 'app_language',
      //   value: language.languageCode,
      // );

      // // Log analytics event
      // FirebaseService.instance.logEvent(
      //   name: 'language_changed',
      //   parameters: {
      //     'language': language.languageCode,
      //     'display_name': language.displayName,
      //   },
      // );

      emit(state.copyWith(
        selectedLanguage: language,
        isLoading: false,
      ));

      HapticFeedback.mediumImpact();
      Console.printSuccess('Language changed to: ${language.displayName}');
    } catch (e) {
      Console.printError('Failed to change language: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to change language',
      ));
    }
  }

  /// Get available languages
  List<AppLanguage> get availableLanguages => AppLanguage.values;

  /// Clear error message
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
