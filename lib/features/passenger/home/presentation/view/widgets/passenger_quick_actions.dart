import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerQuickActions extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isTablet;
  final Animation<double> fadeAnimation;
  final VoidCallback onAvailableTripsPressed;
  final VoidCallback onMyTripsPressed;

  const PassengerQuickActions({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isTablet,
    required this.fadeAnimation,
    required this.onAvailableTripsPressed,
    required this.onMyTripsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        margin: responsive.padding(20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'passenger.home.quickActions'.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(isTablet ? 22 : 20),
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'passenger.home.availableTrips'.tr(),
                    subtitle: 'passenger.home.findYourRide'.tr(),
                    icon: Icons.directions_bus,
                    color: AppColors.primary,
                    onPressed: onAvailableTripsPressed,
                  ),
                ),
                SizedBox(width: responsive.spacing(16)),
                Expanded(
                  child: _buildActionCard(
                    title: 'passenger.home.myTrips'.tr(),
                    subtitle: 'passenger.home.viewBookings'.tr(),
                    icon: Icons.bookmark_outline,
                    color: Colors.green,
                    onPressed: onMyTripsPressed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        child: Container(
          padding: responsive.padding(20, 20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(responsive.spacing(16)),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: responsive.padding(12, 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(12)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: responsive.fontSize(isTablet ? 32 : 28),
                ),
              ),
              SizedBox(height: responsive.spacing(16)),
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(isTablet ? 18 : 16),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: responsive.spacing(6)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: responsive.fontSize(isTablet ? 14 : 12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
