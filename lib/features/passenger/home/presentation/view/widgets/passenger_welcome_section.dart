import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../../generated/locale_keys.g.dart';

class PassengerWelcomeSection extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isTablet;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const PassengerWelcomeSection({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isTablet,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = StorageService.getString('first_name') ?? 'Passenger';
    final timeOfDay = _getTimeOfDay();
    final greeting = _getGreeting(timeOfDay);

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          margin: responsive.padding(20, 20),
          padding: responsive.padding(24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode ? Colors.grey[800]! : Colors.white,
                isDarkMode ? Colors.grey[700]! : Colors.blue[50]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(responsive.spacing(20)),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: responsive.fontSize(isTablet ? 18 : 16),
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      firstName,
                      style: TextStyle(
                        fontSize: responsive.fontSize(isTablet ? 28 : 24),
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(8)),
                    Text(
                      LocaleKeys.passenger_home_whereToGo.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(isTablet ? 16 : 14),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildWelcomeIcon(timeOfDay),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeIcon(String timeOfDay) {
    IconData iconData;
    Color iconColor;

    switch (timeOfDay) {
      case 'morning':
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      case 'afternoon':
        iconData = Icons.wb_sunny_outlined;
        iconColor = Colors.amber;
        break;
      case 'evening':
        iconData = Icons.nights_stay;
        iconColor = Colors.indigo;
        break;
      default:
        iconData = Icons.nights_stay;
        iconColor = Colors.indigo;
    }

    return Container(
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
      ),
      child: Icon(
        iconData,
        size: responsive.fontSize(40),
        color: iconColor,
      ),
    );
  }

  String _getTimeOfDay() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  String _getGreeting(String timeOfDay) {
    switch (timeOfDay) {
      case 'morning':
        return LocaleKeys.passenger_home_goodMorning.tr();
      case 'afternoon':
        return LocaleKeys.passenger_home_goodAfternoon.tr();
      case 'evening':
        return LocaleKeys.passenger_home_goodEvening.tr();
      case 'night':
        return LocaleKeys.passenger_home_goodNight.tr();
      default:
        return LocaleKeys.passenger_home_hello.tr();
    }
  }
}
