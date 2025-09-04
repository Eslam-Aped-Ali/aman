import 'package:flutter/material.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerGenderSelector extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isEditing;
  final String selectedGender;
  final Function(String?) onChanged;

  const PassengerGenderSelector({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isEditing,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(4),
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGender,
                    isExpanded: true,
                    onChanged: isEditing ? onChanged : null,
                    items: ['male', 'female', 'other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.substring(0, 1).toUpperCase() +
                              value.substring(1),
                          style: TextStyle(
                            fontSize: responsive.fontSize(16),
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    dropdownColor: isDarkMode ? Colors.grey[700] : Colors.white,
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
