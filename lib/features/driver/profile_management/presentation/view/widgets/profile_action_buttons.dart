import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onTripHistoryTap;
  final VoidCallback onEarningsReportTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onHelpSupportTap;
  final VoidCallback onLogoutTap;

  const ProfileActionButtons({
    super.key,
    required this.onTripHistoryTap,
    required this.onEarningsReportTap,
    required this.onSettingsTap,
    required this.onHelpSupportTap,
    required this.onLogoutTap,
  });

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
        children: [
          _buildActionButton(
            title: 'Trip History',
            subtitle: 'View your completed trips',
            icon: Icons.history,
            onTap: onTripHistoryTap,
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          _buildDivider(isDarkMode, responsive),
          _buildActionButton(
            title: 'Earnings Report',
            subtitle: 'View your earnings details',
            icon: Icons.account_balance_wallet,
            onTap: onEarningsReportTap,
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          _buildDivider(isDarkMode, responsive),
          _buildActionButton(
            title: 'Settings',
            subtitle: 'App settings and preferences',
            icon: Icons.settings_outlined,
            onTap: onSettingsTap,
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          _buildDivider(isDarkMode, responsive),
          _buildActionButton(
            title: 'Help & Support',
            subtitle: 'Get help or contact support',
            icon: Icons.help_outline,
            onTap: onHelpSupportTap,
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          _buildDivider(isDarkMode, responsive),
          _buildActionButton(
            title: 'Logout',
            subtitle: 'Sign out of your account',
            icon: Icons.logout,
            onTap: onLogoutTap,
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode, ResponsiveUtils responsive) {
    return Divider(
      color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
      height: responsive.spacing(24),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
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
              padding: responsive.padding(12, 12),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.spacing(10)),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: responsive.fontSize(20),
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
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? Colors.red
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  SizedBox(height: responsive.spacing(2)),
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
            Icon(
              Icons.arrow_forward_ios,
              size: responsive.fontSize(16),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
