import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerActionButtons extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final VoidCallback onTripHistoryPressed;
  final VoidCallback onMyBookingsPressed;
  final VoidCallback onFavoriteRoutesPressed;
  final VoidCallback onPaymentMethodsPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onHelpSupportPressed;
  final VoidCallback onLogoutPressed;

  const PassengerActionButtons({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.onTripHistoryPressed,
    required this.onMyBookingsPressed,
    required this.onFavoriteRoutesPressed,
    required this.onPaymentMethodsPressed,
    required this.onSettingsPressed,
    required this.onHelpSupportPressed,
    required this.onLogoutPressed,
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
      child: Column(
        children: [
          _buildActionButton(
            title: 'profile.tripHistory'.tr(),
            subtitle: 'profile.tripHistoryDesc'.tr(),
            icon: Icons.history,
            onTap: onTripHistoryPressed,
          ),
          _buildDivider(),
          _buildActionButton(
            title: 'My Bookings',
            subtitle: 'View your booking history',
            icon: Icons.book_online,
            onTap: onMyBookingsPressed,
          ),
          _buildDivider(),
          _buildActionButton(
            title: 'profile.favoriteRoutes'.tr(),
            subtitle: 'profile.favoriteRoutesDesc'.tr(),
            icon: Icons.favorite_outline,
            onTap: onFavoriteRoutesPressed,
          ),
          _buildDivider(),
          _buildActionButton(
            title: 'profile.paymentMethods'.tr(),
            subtitle: 'profile.paymentMethodsDesc'.tr(),
            icon: Icons.payment,
            onTap: onPaymentMethodsPressed,
          ),
          _buildDivider(),
          _buildActionButton(
            title: 'Settings',
            subtitle: 'App settings and preferences',
            icon: Icons.settings_outlined,
            onTap: onSettingsPressed,
          ),
          _buildDivider(),
          _buildActionButton(
            title: 'Help & Support',
            subtitle: 'Get help or contact support',
            icon: Icons.help_outline,
            onTap: onHelpSupportPressed,
          ),
          _buildDivider(),
          _buildActionButton(
            title: 'Logout',
            subtitle: 'Sign out of your account',
            icon: Icons.logout,
            onTap: onLogoutPressed,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsive.spacing(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.spacing(12)),
              decoration: BoxDecoration(
                color:
                    (isDestructive ? Colors.red : Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.spacing(12)),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.blue,
                size: responsive.fontSize(24),
              ),
            ),
            SizedBox(width: responsive.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  SizedBox(height: responsive.spacing(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              size: responsive.fontSize(16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
      height: responsive.spacing(24),
    );
  }
}
