import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class ContactInfoSection extends StatelessWidget {
  final TextEditingController phoneController;

  const ContactInfoSection({
    super.key,
    required this.phoneController,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildInfoField(
            'Phone Number',
            phoneController,
            Icons.phone,
            false, // Phone number should not be editable
            isDarkMode,
            responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool enabled,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(16),
          ),
          decoration: BoxDecoration(
            color: enabled
                ? (isDarkMode ? Colors.grey[700] : Colors.grey[50])
                : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
            border: enabled
                ? Border.all(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
