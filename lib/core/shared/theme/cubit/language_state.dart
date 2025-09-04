import 'package:equatable/equatable.dart';

class LanguageState extends Equatable {
  final String currentLanguage;
  final List<String> supportedLanguages;
  final bool isChanging;
  final String? error;

  const LanguageState({
    this.currentLanguage = 'en',
    this.supportedLanguages = const ['en', 'ar'],
    this.isChanging = false,
    this.error,
  });

  LanguageState copyWith({
    String? currentLanguage,
    List<String>? supportedLanguages,
    bool? isChanging,
    String? error,
  }) {
    return LanguageState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      isChanging: isChanging ?? this.isChanging,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        currentLanguage,
        supportedLanguages,
        isChanging,
        error,
      ];
}
