import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class CompleteProfileHeader extends StatelessWidget {
  final Animation<Offset> slideAnimation;

  const CompleteProfileHeader({
    super.key,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return SlideTransition(
      position: slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: responsive.padding(16, 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(16)),
            ),
            child: Icon(
              Icons.account_circle,
              color: AppColors.primary,
              size: responsive.fontSize(48),
            ),
          ),
          SizedBox(height: responsive.spacing(24)),
          Text(
            'Complete Your Driver Profile',
            style: TextStyle(
              fontSize: responsive.fontSize(28),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Text(
            'Please provide your information to complete your driver registration',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
