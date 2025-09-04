import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class DriverStatsSection extends StatelessWidget {
  const DriverStatsSection({super.key});

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
                Icons.local_shipping,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Driver Statistics',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'This Month',
                  '23',
                  'Completed Trips',
                  Icons.check_circle,
                  Colors.green,
                  isDarkMode,
                  responsive,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: _buildStatCard(
                  'This Week',
                  '6',
                  'Trips',
                  Icons.directions_bus,
                  Colors.blue,
                  isDarkMode,
                  responsive,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  '2,450',
                  'OMR',
                  Icons.attach_money,
                  Colors.orange,
                  isDarkMode,
                  responsive,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: _buildStatCard(
                  'Avg Rating',
                  '4.8',
                  'Stars',
                  Icons.star,
                  Colors.amber,
                  isDarkMode,
                  responsive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      padding: responsive.padding(12, 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: responsive.fontSize(20)),
          SizedBox(height: responsive.spacing(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: responsive.fontSize(10),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize(10),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
