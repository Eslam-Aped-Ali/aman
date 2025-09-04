import 'package:flutter/material.dart';

class ResponsiveUtils {
  static ResponsiveUtils of(BuildContext context) {
    return ResponsiveUtils._(context);
  }

  const ResponsiveUtils._(this.context);
  final BuildContext context;

  // Screen size getters
  Size get screenSize => MediaQuery.of(context).size;
  double get width => screenSize.width;
  double get height => screenSize.height;

  // Device type detection
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;
  bool get isLargeTablet => width >= 800 && width < 1024;

  // Responsive scaling based on screen width
  double get scaleFactor {
    if (isMobile) return 1.0;
    if (isTablet && width < 700) return 1.2;
    if (isTablet && width < 800) return 1.4;
    if (isLargeTablet) return 1.6;
    return 1.8; // Desktop/very large tablets
  }

  // Font scaling - more aggressive for readability
  double get fontScale {
    if (isMobile) return 1.0;
    if (isTablet && width < 700) return 1.3;
    if (isTablet && width < 800) return 1.5;
    if (isLargeTablet) return 1.7;
    return 2.0; // Desktop/very large tablets
  }

  // Spacing scaling - less aggressive than font
  double get spacingScale {
    if (isMobile) return 1.0;
    if (isTablet && width < 700) return 1.1;
    if (isTablet && width < 800) return 1.2;
    if (isLargeTablet) return 1.3;
    return 1.4; // Desktop/very large tablets
  }

  // Responsive font sizes
  double fontSize(double baseSize) => baseSize * fontScale;

  // Responsive spacing
  double spacing(double baseSpacing) => baseSpacing * spacingScale;

  // Responsive padding
  EdgeInsets padding(double horizontal, double vertical) {
    return EdgeInsets.symmetric(
      horizontal: spacing(horizontal),
      vertical: spacing(vertical),
    );
  }

  // Responsive margin
  EdgeInsets margin(double horizontal, double vertical) {
    return EdgeInsets.symmetric(
      horizontal: spacing(horizontal),
      vertical: spacing(vertical),
    );
  }

  // Content max width for better readability on large screens
  double get maxContentWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return width * 0.8;
    return 1200.0; // Max width for desktop
  }

  // Responsive grid column count
  int get gridColumns {
    if (isMobile) return 1;
    if (width < 700) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  // Responsive card width
  double get cardWidth {
    if (isMobile) return width * 0.9;
    if (isTablet) return (width * 0.8) / 2;
    return 400.0; // Fixed width for desktop
  }

  // Quick access methods for common use cases
  TextStyle headline1(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontSize: fontSize(32),
        );
  }

  TextStyle headline2(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontSize: fontSize(28),
        );
  }

  TextStyle headline3(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontSize: fontSize(24),
        );
  }

  TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: fontSize(18),
        );
  }

  TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: fontSize(16),
        );
  }

  TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: fontSize(14),
        );
  }
}

// Extension for easier access
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils.of(this);
}

///usage example
///
///```dart
/// final responsive = context.responsive;
/// Text(
///   'Hello World',
///   style: responsive.headline1(context),
/// )
///```
