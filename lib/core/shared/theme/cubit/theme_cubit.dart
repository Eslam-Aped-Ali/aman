import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'app_theme_mode';

  ThemeCubit() : super(const ThemeState());

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to system mode if no preference is saved
    final themeModeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
    final themeMode = AppThemeMode.values[themeModeIndex];

    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> setTheme(AppThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);

    emit(state.copyWith(themeMode: themeMode));
  }

  void toggleTheme() {
    final currentIndex = state.themeMode.index;
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    setTheme(AppThemeMode.values[nextIndex]);
  }

  void onSystemThemeChanged() {
    // Force a rebuild when system theme changes
    if (state.themeMode == AppThemeMode.system) {
      emit(state.copyWith(themeMode: AppThemeMode.system));
    }
  }
}
