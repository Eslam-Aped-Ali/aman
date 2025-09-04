import 'package:flutter/material.dart';

import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showArrow;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(8)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(responsive.spacing(8)),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive.spacing(8)),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: responsive.fontSize(20),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: trailing ??
            (showArrow && onTap != null
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: responsive.fontSize(16),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  )
                : null),
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(8),
        ),
      ),
    );
  }
}

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(4),
        vertical: responsive.spacing(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: responsive.fontSize(24),
          ),
          SizedBox(width: responsive.spacing(12)),
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const ProfileStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(responsive.spacing(12)),
            decoration: BoxDecoration(
              color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(8)),
            ),
            child: Icon(
              icon,
              color: color ?? theme.colorScheme.primary,
              size: responsive.fontSize(24),
            ),
          ),
          SizedBox(height: responsive.spacing(12)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(20),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
