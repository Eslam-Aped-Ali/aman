import 'package:flutter/material.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerInfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const PassengerInfoField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.enabled,
    required this.isDarkMode,
    required this.responsive,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? theme.colorScheme.primary : Colors.grey,
              size: responsive.fontSize(20),
            ),
            filled: true,
            fillColor: enabled
                ? (isDarkMode ? Colors.grey[700] : Colors.grey[50])
                : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(16),
              vertical: responsive.spacing(16),
            ),
          ),
        ),
      ],
    );
  }
}
