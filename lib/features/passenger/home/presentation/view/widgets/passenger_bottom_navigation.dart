import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PassengerBottomNavigation extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isTablet;
  final int currentIndex;
  final Function(int) onTap;

  const PassengerBottomNavigation({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isTablet,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontSize: responsive.fontSize(isTablet ? 14 : 12),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: responsive.fontSize(isTablet ? 14 : 12),
          fontWeight: FontWeight.w500,
        ),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home_outlined, Icons.home, 0),
            label: 'passenger.navigation.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.search_outlined, Icons.search, 1),
            label: 'passenger.navigation.search'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.bookmark_outline, Icons.bookmark, 2),
            label: 'passenger.navigation.bookings'.tr(),
          ),
          BottomNavigationBarItem(
            icon:
                _buildNavIcon(Icons.location_on_outlined, Icons.location_on, 3),
            label: 'passenger.navigation.tracking'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.person_outline, Icons.person, 4),
            label: 'passenger.navigation.profile'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData inactiveIcon, IconData activeIcon, int index) {
    final isSelected = currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(responsive.spacing(isSelected ? 8 : 6)),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: Icon(
        isSelected ? activeIcon : inactiveIcon,
        size: responsive.fontSize(isTablet ? 28 : 24),
      ),
    );
  }
}
