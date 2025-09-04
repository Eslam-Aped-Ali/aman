import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerBirthDateSelector extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isEditing;
  final DateTime? selectedBirthDate;
  final VoidCallback onTap;

  const PassengerBirthDateSelector({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isEditing,
    required this.selectedBirthDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Date',
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        GestureDetector(
          onTap: isEditing ? onTap : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(16),
              vertical: responsive.spacing(16),
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: responsive.fontSize(20),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: Text(
                    selectedBirthDate != null
                        ? DateFormat('MMM dd, yyyy').format(selectedBirthDate!)
                        : 'Select birth date',
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      color: selectedBirthDate != null
                          ? (isDarkMode ? Colors.white : Colors.black87)
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
                if (isEditing)
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.primary,
                    size: responsive.fontSize(24),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
