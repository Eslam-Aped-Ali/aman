import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class DriverProfileHeader extends StatelessWidget {
  final TextEditingController nameController;
  final bool isEditing;
  final VoidCallback onProfileImageTap;

  const DriverProfileHeader({
    super.key,
    required this.nameController,
    required this.isEditing,
    required this.onProfileImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;
    final isTablet = responsive.isTablet;

    return Container(
      padding: responsive.padding(24, 24),
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
          GestureDetector(
            onTap: isEditing ? onProfileImageTap : null,
            child: Stack(
              children: [
                Container(
                  width: isTablet ? 120.w : 100.w,
                  height: isTablet ? 120.w : 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: isTablet ? 50.w : 40.w,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Colors.grey[800]! : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            nameController.text.isNotEmpty
                ? nameController.text
                : 'Driver Name',
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(12),
              vertical: responsive.spacing(6),
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(20)),
            ),
            child: Text(
              'Active Driver',
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('4.8', 'Rating', isDarkMode, responsive),
              Container(
                height: 30,
                width: 1,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
              _buildStatColumn('127', 'Trips', isDarkMode, responsive),
              Container(
                height: 30,
                width: 1,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
              _buildStatColumn('3.2K', 'KMs', isDarkMode, responsive),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
      String value, String label, bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(20),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
