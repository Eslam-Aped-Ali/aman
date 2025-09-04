import 'package:flutter/material.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerQuickStats extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final String totalTrips;
  final String savedRoutes;
  final String rating;

  const PassengerQuickStats({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.totalTrips,
    required this.savedRoutes,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: 'Total Trips',
              value: totalTrips,
              icon: Icons.directions_car,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: _buildStatItem(
              title: 'Saved Routes',
              value: savedRoutes,
              icon: Icons.bookmark,
              color: Colors.green,
            ),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: _buildStatItem(
              title: 'Rating',
              value: rating,
              icon: Icons.star,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.spacing(12)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          child: Icon(
            icon,
            color: color,
            size: responsive.fontSize(24),
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(18),
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
