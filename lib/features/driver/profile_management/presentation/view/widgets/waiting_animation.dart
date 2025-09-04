import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class WaitingAnimation extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const WaitingAnimation({
    super.key,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: Container(
            width: responsive.spacing(120),
            height: responsive.spacing(120),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.access_time,
              size: responsive.fontSize(60),
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}
