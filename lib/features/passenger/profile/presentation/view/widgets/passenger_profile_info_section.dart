import 'package:flutter/material.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerProfileInfoSection extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final String title;
  final IconData icon;
  final bool isEditable;
  final bool isEditing;
  final VoidCallback? onEditPressed;
  final List<Widget> children;

  const PassengerProfileInfoSection({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.title,
    required this.icon,
    this.isEditable = false,
    required this.isEditing,
    this.onEditPressed,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
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
              if (isEditable) const Spacer(),
              if (isEditable)
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.save : Icons.edit,
                    color: theme.colorScheme.primary,
                    size: responsive.fontSize(24),
                  ),
                  onPressed: onEditPressed,
                ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          ...children,
        ],
      ),
    );
  }
}
