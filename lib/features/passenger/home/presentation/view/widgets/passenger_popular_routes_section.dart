import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../../generated/locale_keys.g.dart';

class PopularRoute {
  final String fromLocation;
  final String toLocation;
  final String fromLocationAr;
  final String toLocationAr;
  final String duration;
  final double price;
  final String nextDeparture;
  final bool isAvailable;

  PopularRoute({
    required this.fromLocation,
    required this.toLocation,
    required this.fromLocationAr,
    required this.toLocationAr,
    required this.duration,
    required this.price,
    required this.nextDeparture,
    required this.isAvailable,
  });
}

class PassengerPopularRoutesSection extends StatelessWidget {
  final bool isDarkMode;
  final ResponsiveUtils responsive;
  final bool isTablet;
  final bool isArabic;
  final Animation<double> fadeAnimation;
  final List<PopularRoute> popularRoutes;
  final Function(PopularRoute) onRoutePressed;

  const PassengerPopularRoutesSection({
    super.key,
    required this.isDarkMode,
    required this.responsive,
    required this.isTablet,
    required this.isArabic,
    required this.fadeAnimation,
    required this.popularRoutes,
    required this.onRoutePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (popularRoutes.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        margin: responsive.padding(20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.passenger_home_popularRoutes.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(isTablet ? 22 : 20),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all routes
                  },
                  child: Text(
                    LocaleKeys.passenger_home_seeAll.tr(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: responsive.fontSize(isTablet ? 16 : 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.spacing(16)),
            SizedBox(
              height: responsive.spacing(isTablet ? 230 : 210),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularRoutes.length,
                itemBuilder: (context, index) {
                  final route = popularRoutes[index];
                  return Container(
                    width: responsive.spacing(isTablet ? 320 : 280),
                    margin: EdgeInsets.only(right: responsive.spacing(16)),
                    child: _buildRouteCard(route),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(PopularRoute route) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onRoutePressed(route),
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
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Route header
              Row(
                children: [
                  Container(
                    padding: responsive.padding(8, 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(8)),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: AppColors.primary,
                      size: responsive.fontSize(20),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(8),
                      vertical: responsive.spacing(4),
                    ),
                    decoration: BoxDecoration(
                      color: route.isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(6)),
                    ),
                    child: Text(
                      route.isAvailable
                          ? LocaleKeys.passenger_home_available.tr()
                          : LocaleKeys.passenger_home_unavailable.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(10),
                        color: route.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsive.spacing(12)),

              // Route path
              Flexible(
                child: Text(
                  isArabic
                      ? '${route.fromLocationAr} → ${route.toLocationAr}'
                      : '${'locations.${route.fromLocation}'.tr()} → ${'locations.${route.toLocation}'.tr()}',
                  style: TextStyle(
                    fontSize: responsive.fontSize(isTablet ? 18 : 16),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: responsive.spacing(12)),

              // Route details
              Row(
                children: [
                  _buildRouteDetail(
                    Icons.access_time,
                    route.duration,
                    Colors.blue,
                  ),
                  SizedBox(width: responsive.spacing(16)),
                  _buildRouteDetail(
                    Icons.attach_money,
                    '${route.price.toStringAsFixed(1)} ${LocaleKeys.common_currency.tr()}',
                    Colors.green,
                  ),
                ],
              ),

              SizedBox(height: responsive.spacing(12)),

              // Next departure
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  SizedBox(width: responsive.spacing(4)),
                  Text(
                    LocaleKeys.passenger_home_nextDeparture.tr(),
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    route.nextDeparture,
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteDetail(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: responsive.fontSize(14),
          color: color,
        ),
        SizedBox(width: responsive.spacing(4)),
        Text(
          text,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        margin: responsive.padding(20, 20),
        padding: responsive.padding(24, 24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(16)),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.route_outlined,
              size: responsive.fontSize(60),
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: responsive.spacing(16)),
            Text(
              LocaleKeys.passenger_home_noPopularRoutes.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
