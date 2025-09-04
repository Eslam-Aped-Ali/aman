import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../domain/entities/driver_profile.dart';

class ApprovalProfileSummary extends StatelessWidget {
  final DriverProfile? driverProfile;

  const ApprovalProfileSummary({
    super.key,
    this.driverProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    if (driverProfile == null) {
      return Container(
        padding: responsive.padding(20, 20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(16)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Profile information not available',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submitted Information',
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildInfoRow(
            'Name',
            driverProfile!.name,
            Icons.person,
            isDarkMode,
            responsive,
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildInfoRow(
            'Phone',
            driverProfile!.phoneNumber,
            Icons.phone,
            isDarkMode,
            responsive,
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildInfoRow(
            'Gender',
            driverProfile!.gender.name.toUpperCase(),
            driverProfile!.gender == Gender.male ? Icons.male : Icons.female,
            isDarkMode,
            responsive,
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildInfoRow(
            'Age',
            '${driverProfile!.age} years',
            Icons.calendar_today,
            isDarkMode,
            responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
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
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
