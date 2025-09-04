import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class CurrentTripsHeader extends StatelessWidget {
  final VoidCallback onRefresh;

  const CurrentTripsHeader({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      padding: responsive.padding(20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.grey[900]!, Colors.black]
              : [AppColors.primary.withOpacity(0.05), Colors.white],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: responsive.padding(12, 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
            child: Icon(
              Icons.assignment,
              color: AppColors.primary,
              size: responsive.fontSize(24),
            ),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Trips',
                  style: TextStyle(
                    fontSize: responsive.fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primary,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  'Manage your assigned and active trips',
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: responsive.fontSize(24),
            ),
          ),
        ],
      ),
    );
  }
}
