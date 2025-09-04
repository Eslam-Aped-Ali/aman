import 'package:flutter/material.dart';

class AnimationHelper {
  /// Clamps animation values to prevent overflow
  static double clampOpacity(double value) {
    return value.clamp(0.0, 1.0);
  }

  /// Safe animation controller dispose
  static void safeDisposeController(AnimationController? controller) {
    try {
      controller?.dispose();
    } catch (e) {
      // Controller might already be disposed, ignore error
      debugPrint('AnimationController dispose error: $e');
    }
  }

  /// Creates a performance-optimized fade transition
  static Widget buildOptimizedFadeTransition({
    required Animation<double> animation,
    required Widget child,
    Duration? duration,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: clampOpacity(animation.value),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Creates curves optimized for mobile performance
  static const Curve performanceEaseIn = Curves.easeInQuad;
  static const Curve performanceEaseOut = Curves.easeOutQuad;
  static const Curve performanceEaseInOut = Curves.easeInOutQuad;
}
