import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerSearchBar extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isTablet;
  final Animation<Offset> slideAnimation;
  final VoidCallback onSearchTap;

  const PassengerSearchBar({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isTablet,
    required this.slideAnimation,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: Container(
        margin: responsive.padding(20, 20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(responsive.spacing(16)),
            child: Container(
              padding: responsive.padding(16, 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(responsive.spacing(16)),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: responsive.padding(10, 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(12)),
                    ),
                    child: Icon(
                      Icons.search,
                      color: AppColors.primary,
                      size: responsive.fontSize(24),
                    ),
                  ),
                  SizedBox(width: responsive.spacing(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'passenger.home.searchDestination'.tr(),
                          style: TextStyle(
                            fontSize: responsive.fontSize(isTablet ? 18 : 16),
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: responsive.spacing(4)),
                        Text(
                          'passenger.home.whereWouldYouLikeToGo'.tr(),
                          style: TextStyle(
                            fontSize: responsive.fontSize(isTablet ? 14 : 12),
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                    size: responsive.fontSize(16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
