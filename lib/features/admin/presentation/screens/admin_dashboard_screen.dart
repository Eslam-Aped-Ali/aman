import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/shared/utils/user_exprience/flash_helper.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(theme, isDarkMode),
            SizedBox(height: 24.h),
            _buildStatsGrid(theme, isDarkMode),
            SizedBox(height: 24.h),
            _buildQuickActions(theme, isDarkMode),
            SizedBox(height: 24.h),
            _buildRecentActivity(theme, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Admin',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Manage your transportation system',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.admin_panel_settings,
            size: 60.w,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, bool isDarkMode) {
    final stats = [
      {
        'title': 'Total Drivers',
        'value': '247',
        'icon': Icons.local_taxi,
        'color': Colors.blue,
        'change': '+12%',
      },
      {
        'title': 'Active Passengers',
        'value': '1,834',
        'icon': Icons.people,
        'color': Colors.green,
        'change': '+8%',
      },
      {
        'title': 'Today\'s Trips',
        'value': '156',
        'icon': Icons.directions_car,
        'color': Colors.orange,
        'change': '+23%',
      },
      {
        'title': 'Revenue',
        'value': '\$2,847',
        'icon': Icons.attach_money,
        'color': Colors.purple,
        'change': '+15%',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.6, // Further reduced to give more vertical space
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
          change: stat['change'] as String,
          theme: theme,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w), // Reduced padding from 16.w
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Changed to spaceBetween
        mainAxisSize: MainAxisSize.max, // Allow full height usage
        children: [
          // Top row with icon and change indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 22.w, // Slightly reduced size
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 6.w, vertical: 1.h), // Reduced vertical padding
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 9.sp, // Reduced from 10.sp
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),

          // Middle section with value
          Expanded(
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp, // Further reduced from 20.sp
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Bottom section with title
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp, // Reduced from 11.sp
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1, // Reduced to 1 line to prevent overflow
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isDarkMode) {
    final actions = [
      {
        'title': 'Manage Drivers',
        'icon': Icons.local_taxi,
        'color': Colors.blue,
      },
      {
        'title': 'View Reports',
        'icon': Icons.analytics,
        'color': Colors.green,
      },
      {
        'title': 'User Management',
        'icon': Icons.people,
        'color': Colors.orange,
      },
      {
        'title': 'System Settings',
        'icon': Icons.settings,
        'color': Colors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 2.8, // Slightly reduced to provide more height
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              title: action['title'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              theme: theme,
              isDarkMode: isDarkMode,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to respective screen - placeholder for future implementation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feature coming soon!')),
        );
        FlashHelper.showToast('admin.manageSoon'.tr());
      },
      child: Container(
        padding: EdgeInsets.all(10.w), // Reduced padding
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            Container(
              padding: EdgeInsets.all(6.w), // Reduced padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18.w, // Reduced icon size
              ),
            ),
            SizedBox(width: 8.w), // Reduced spacing
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp, // Further reduced font size
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                maxLines: 1, // Reduced to single line
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme, bool isDarkMode) {
    final activities = [
      {
        'title': 'New driver application',
        'subtitle': 'John Doe submitted documents',
        'time': '2 hours ago',
        'icon': Icons.person_add,
        'color': Colors.blue,
      },
      {
        'title': 'System maintenance',
        'subtitle': 'Scheduled update completed',
        'time': '4 hours ago',
        'icon': Icons.build,
        'color': Colors.green,
      },
      {
        'title': 'Payment processed',
        'subtitle': 'Weekly driver payouts sent',
        'time': '1 day ago',
        'icon': Icons.payment,
        'color': Colors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Divider(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              height: 1,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size: 20.w,
                  ),
                ),
                title: Text(
                  activity['title'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  activity['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: Text(
                  activity['time'] as String,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
