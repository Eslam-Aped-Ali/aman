import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class DriverPreferencesSection extends StatelessWidget {
  const DriverPreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Driver Preferences',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildPreferenceItem(
            'Notifications',
            'Receive trip notifications',
            true,
            Icons.notifications,
            isDarkMode,
            responsive,
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildPreferenceItem(
            'Auto Accept',
            'Automatically accept assigned trips',
            false,
            Icons.auto_awesome,
            isDarkMode,
            responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: responsive.fontSize(20),
        ),
        SizedBox(width: responsive.spacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            // Handle preference change - implement in parent widget
          },
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}
