import 'package:flutter/material.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerProfileHeader extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isTablet;
  final bool isEditing;
  final String firstName;
  final String lastName;
  final VoidCallback? onImageTap;

  const PassengerProfileHeader({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isTablet,
    required this.isEditing,
    required this.firstName,
    required this.lastName,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            onTap: isEditing ? onImageTap : null,
            child: Stack(
              children: [
                Container(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: isTablet ? 50 : 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Colors.grey[800]! : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            '$firstName $lastName',
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(12),
              vertical: responsive.spacing(6),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
            child: Text(
              'Passenger',
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
