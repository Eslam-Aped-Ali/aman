import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  static const String _languageKey = 'app_language';

  LanguageCubit() : super(const LanguageState());

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'en';
    emit(state.copyWith(
      currentLanguage: savedLanguage,
      supportedLanguages: const ['en', 'ar'],
    ));
  }

  Future<void> changeLanguage(String languageCode, BuildContext context) async {
    if (state.currentLanguage == languageCode) return;

    try {
      emit(state.copyWith(isChanging: true));

      // Save the language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      // Change the locale immediately
      final locale = Locale(languageCode);
      await context.setLocale(locale);

      emit(state.copyWith(
        currentLanguage: languageCode,
        isChanging: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isChanging: false,
        error: 'Failed to change language: $e',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  String get currentLanguageName {
    switch (state.currentLanguage) {
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }

  bool get isArabic => state.currentLanguage == 'ar';
  bool get isEnglish => state.currentLanguage == 'en';
}
