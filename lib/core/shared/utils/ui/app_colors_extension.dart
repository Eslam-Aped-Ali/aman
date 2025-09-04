import 'package:flutter/material.dart';
import '../../theme/colors/app_colors.dart';

/// Extension to provide a simple primaryColor property for consistency
/// with the reference implementation
extension AppColorsExtension on AppColors {
  static Color get primaryColor => AppColors.primary;
}
