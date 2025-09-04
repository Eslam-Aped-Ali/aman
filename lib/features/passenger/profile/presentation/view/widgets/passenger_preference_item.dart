import 'package:flutter/material.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerPreferenceItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool isDarkMode;
  final ResponsiveUtils responsive;

  const PassengerPreferenceItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isDarkMode,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
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
        trailing,
      ],
    );
  }
}
