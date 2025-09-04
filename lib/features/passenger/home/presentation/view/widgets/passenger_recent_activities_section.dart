import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

enum ActivityType { booking, trip, payment, cancellation }

enum ActivityStatus { completed, pending, cancelled, inProgress }

class RecentActivity {
  final String id;
  final ActivityType type;
  final ActivityStatus status;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? amount;

  RecentActivity({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.amount,
  });
}

class PassengerRecentActivitiesSection extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isTablet;
  final Animation<double> fadeAnimation;
  final List<RecentActivity> recentActivities;
  final Function(RecentActivity) onActivityPressed;

  const PassengerRecentActivitiesSection({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isTablet,
    required this.fadeAnimation,
    required this.recentActivities,
    required this.onActivityPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (recentActivities.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        margin: responsive.padding(20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'passenger.home.recentActivities'.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(isTablet ? 22 : 20),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to activity history
                  },
                  child: Text(
                    'passenger.home.seeAll'.tr(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: responsive.fontSize(isTablet ? 16 : 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.spacing(16)),
            Container(
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
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActivities
                    .take(5)
                    .length, // Show max 5 recent activities
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final activity = recentActivities[index];
                  return _buildActivityItem(activity);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    final activityIcon = _getActivityIcon(activity.type);
    final statusColor = _getStatusColor(activity.status);
    final statusText = _getStatusText(activity.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onActivityPressed(activity),
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        child: Padding(
          padding: responsive.padding(16, 16),
          child: Row(
            children: [
              Container(
                padding: responsive.padding(12, 12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(12)),
                ),
                child: Icon(
                  activityIcon,
                  color: statusColor,
                  size: responsive.fontSize(24),
                ),
              ),
              SizedBox(width: responsive.spacing(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: TextStyle(
                              fontSize: responsive.fontSize(isTablet ? 18 : 16),
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (activity.amount != null)
                          Text(
                            activity.amount!,
                            style: TextStyle(
                              fontSize: responsive.fontSize(isTablet ? 16 : 14),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        fontSize: responsive.fontSize(isTablet ? 14 : 12),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: responsive.spacing(8)),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(8),
                            vertical: responsive.spacing(4),
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(responsive.spacing(6)),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: responsive.fontSize(10),
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimestamp(activity.timestamp),
                          style: TextStyle(
                            fontSize: responsive.fontSize(isTablet ? 12 : 10),
                            color: isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsive.spacing(8)),
              Icon(
                Icons.arrow_forward_ios,
                size: responsive.fontSize(14),
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        margin: responsive.padding(20, 20),
        padding: responsive.padding(24, 24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(16)),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_outlined,
              size: responsive.fontSize(60),
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: responsive.spacing(16)),
            Text(
              'passenger.home.noRecentActivities'.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.spacing(8)),
            Text(
              'passenger.home.startBookingToSeeActivities'.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.booking:
        return Icons.book_online;
      case ActivityType.trip:
        return Icons.directions_bus;
      case ActivityType.payment:
        return Icons.payment;
      case ActivityType.cancellation:
        return Icons.cancel_outlined;
    }
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.pending:
        return Colors.orange;
      case ActivityStatus.cancelled:
        return Colors.red;
      case ActivityStatus.inProgress:
        return Colors.blue;
    }
  }

  String _getStatusText(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return 'passenger.home.completed'.tr();
      case ActivityStatus.pending:
        return 'passenger.home.pending'.tr();
      case ActivityStatus.cancelled:
        return 'passenger.home.cancelled'.tr();
      case ActivityStatus.inProgress:
        return 'passenger.home.inProgress'.tr();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'passenger.home.justNow'.tr();
    } else if (difference.inHours < 1) {
      return 'passenger.home.minutesAgo'
          .tr(args: [difference.inMinutes.toString()]);
    } else if (difference.inDays < 1) {
      return 'passenger.home.hoursAgo'
          .tr(args: [difference.inHours.toString()]);
    } else if (difference.inDays < 7) {
      return 'passenger.home.daysAgo'.tr(args: [difference.inDays.toString()]);
    } else {
      return DateFormat.MMMd().format(timestamp);
    }
  }
}
