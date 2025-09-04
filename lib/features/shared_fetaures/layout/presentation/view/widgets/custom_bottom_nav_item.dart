import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../core/shared/commonWidgets/custtoms/custom_image.dart';
import '../../../../../../core/shared/utils/extensions/extensions.dart';
import '../../../../../../generated/assets.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../navigationController/navigation_bloc.dart';
import '../../navigationController/navigation_event.dart';
import '../../navigationController/navigation_state.dart';

// Helper function to get localized navigation title
String _getNavigationTitle(String userType, int index) {
  switch (userType.toLowerCase()) {
    case 'admin':
      switch (index) {
        case 0:
          return LocaleKeys.navigation_admin_dashboard.tr();
        case 1:
          return LocaleKeys.navigation_admin_trips.tr();
        case 2:
          return LocaleKeys.navigation_admin_manage.tr();
        case 3:
          return LocaleKeys.navigation_admin_analytics.tr();
        case 4:
          return LocaleKeys.navigation_admin_profile.tr();
        default:
          return LocaleKeys.navigation_admin_dashboard.tr();
      }
    case 'driver':
      switch (index) {
        case 0:
          return LocaleKeys.navigation_driver_home.tr();
        case 1:
          return LocaleKeys.navigation_driver_route.tr();
        case 2:
          return LocaleKeys.navigation_driver_passengers.tr();
        case 3:
          return LocaleKeys.navigation_driver_history.tr();
        case 4:
          return LocaleKeys.navigation_driver_profile.tr();
        default:
          return LocaleKeys.navigation_driver_home.tr();
      }
    case 'passenger':
    default:
      switch (index) {
        case 0:
          return LocaleKeys.navigation_passenger_home.tr();
        case 1:
          return LocaleKeys.navigation_passenger_trips.tr();
        case 2:
          return LocaleKeys.navigation_passenger_liveTrack.tr();
        case 3:
          return LocaleKeys.navigation_passenger_booking.tr();
        case 4:
          return LocaleKeys.navigation_passenger_profile.tr();
        default:
          return LocaleKeys.navigation_passenger_home.tr();
      }
  }
}

// Helper function to get appropriate icons for navigation items
Map<String, String> _getNavigationIcons(
    String userType, int index, bool isActive) {
  switch (userType.toLowerCase()) {
    case 'admin':
      switch (index) {
        case 0: // Dashboard
          return {
            'icon': 'assets/icons/dashboard.svg',
            'activeIcon': 'assets/icons/dashboard_active.svg',
          };
        case 1: // Trips
          return {
            'icon': 'assets/icons/bus_trips.svg',
            'activeIcon': 'assets/icons/bus_trips_active.svg',
          };
        case 2: // Manage
          return {
            'icon': 'assets/icons/manage.svg',
            'activeIcon': 'assets/icons/manage_active.svg',
          };
        case 3: // Analytics
          return {
            'icon': 'assets/icons/analytics.svg',
            'activeIcon': 'assets/icons/analytics_active.svg',
          };
        case 4: // Profile
          return {
            'icon': Assets.icons.profileSvg.path,
            'activeIcon': Assets.icons.profileActive.path,
          };
      }
    case 'driver':
      switch (index) {
        case 0: // Home
          return {
            'icon': Assets.icons.homeSvg.path,
            'activeIcon': Assets.icons.homeActive.path,
          };
        case 1: // Route
          return {
            'icon': 'assets/icons/route_nav.svg',
            'activeIcon': 'assets/icons/route_nav_active.svg',
          };
        case 2: // Passengers
          return {
            'icon': 'assets/icons/passengers.svg',
            'activeIcon': 'assets/icons/passengers_active.svg',
          };
        case 3: // History
          return {
            'icon': 'assets/icons/history.svg',
            'activeIcon': 'assets/icons/history_active.svg',
          };
        case 4: // Profile
          return {
            'icon': Assets.icons.profileSvg.path,
            'activeIcon': Assets.icons.profileActive.path,
          };
      }
    case 'passenger':
    default:
      switch (index) {
        case 0: // Home
          return {
            'icon': Assets.icons.homeSvg.path,
            'activeIcon': Assets.icons.homeActive.path,
          };
        case 1: // Trips
          return {
            'icon': 'assets/icons/bus_trips.svg',
            'activeIcon': 'assets/icons/bus_trips_active.svg',
          };
        case 2: // Live Track
          return {
            'icon': 'assets/icons/live_track.svg',
            'activeIcon': 'assets/icons/live_track_active.svg',
          };
        case 3: // Booking
          return {
            'icon': 'assets/icons/booking.svg',
            'activeIcon': 'assets/icons/booking_active.svg',
          };
        case 4: // Profile
          return {
            'icon': Assets.icons.profileSvg.path,
            'activeIcon': Assets.icons.profileActive.path,
          };
      }
  }

  // Fallback
  return {
    'icon': Assets.icons.homeSvg.path,
    'activeIcon': Assets.icons.homeActive.path,
  };
}

BottomNavigationBarItem buildBottomNavigationBarItem(
        {required String icon, required bool isActive, String? label}) =>
    BottomNavigationBarItem(
      label: label ?? '',
      icon: Container(
        decoration: BoxDecoration(
          // color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 9.8),
        child: Image(
          image: AssetImage(icon),
          width: 25,
        ),
      ),
      activeIcon: Container(
        decoration: BoxDecoration(
          // color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 9.8),
        child: Image(
          image: AssetImage(icon),
          width: 25,
        ),
      ),
    );

Widget buildNavItem({
  required BuildContext context,
  required int index,
  required String icon,
  required String tittle,
  required bool isActive,
  required NavigationBloc bloc,
}) =>
    Expanded(
      child: GestureDetector(
        onTap: () => bloc.add(NavigateToPage(index)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 55.h), // Constrain height
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImage(
                icon,
                width: 22.w,
                color: isActive == true
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
              ).withPadding(vertical: 2.h), // Reduced padding
              Flexible(
                child: Text(
                  tittle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.sp, // Slightly reduced font size
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

class BottomNavItem extends StatelessWidget {
  final String? imageData;
  final String? tittle;
  final VoidCallback? onTap;
  final bool isSelected;
  final int index;
  const BottomNavItem(
      {super.key,
      this.imageData,
      this.tittle,
      this.onTap,
      this.index = 0,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                imageData!,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  BlendMode.srcIn,
                ),
                width: 20.w,
              ).withPadding(vertical: 3.h),
              Text(
                tittle!,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}

Widget buildCustomBottomNavigationBar(
    BuildContext context, NavigationState state, NavigationBloc bloc) {
  // Get user type from the bloc
  final userType = bloc.userType?.toLowerCase();

  return SizedBox(
    height: 60.h, // Constrain the height to prevent overflow
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _buildNavigationItems(context, state, bloc, userType),
    ),
  );
}

// Wrap the navigation items in a widget that rebuilds on locale change
Widget buildLocalizedBottomNavigationBar(
    BuildContext context, NavigationState state, NavigationBloc bloc) {
  // This will rebuild automatically when the locale changes because
  // the translation functions (.tr()) will trigger a rebuild
  return buildCustomBottomNavigationBar(context, state, bloc);
}

List<Widget> _buildNavigationItems(BuildContext context, NavigationState state,
    NavigationBloc bloc, String? userType) {
  switch (userType) {
    case 'admin':
      return _buildAdminNavItems(context, state, bloc);
    case 'driver':
      return _buildDriverNavItems(context, state, bloc);
    case 'passenger':
    default:
      return _buildPassengerNavItems(context, state, bloc);
  }
}

List<Widget> _buildAdminNavItems(
    BuildContext context, NavigationState state, NavigationBloc bloc) {
  return List.generate(5, (index) {
    final iconData =
        _getNavigationIcons('admin', index, state.currentIndex == index);
    return buildNavItem(
      context: context,
      tittle: _getNavigationTitle('admin', index),
      index: index,
      icon: state.currentIndex == index
          ? iconData['activeIcon']!
          : iconData['icon']!,
      isActive: state.currentIndex == index,
      bloc: bloc,
    );
  });
}

List<Widget> _buildDriverNavItems(
    BuildContext context, NavigationState state, NavigationBloc bloc) {
  return List.generate(5, (index) {
    final iconData =
        _getNavigationIcons('driver', index, state.currentIndex == index);
    return buildNavItem(
      context: context,
      tittle: _getNavigationTitle('driver', index),
      index: index,
      icon: state.currentIndex == index
          ? iconData['activeIcon']!
          : iconData['icon']!,
      isActive: state.currentIndex == index,
      bloc: bloc,
    );
  });
}

List<Widget> _buildPassengerNavItems(
    BuildContext context, NavigationState state, NavigationBloc bloc) {
  return List.generate(5, (index) {
    final iconData =
        _getNavigationIcons('passenger', index, state.currentIndex == index);
    return buildNavItem(
      context: context,
      tittle: _getNavigationTitle('passenger', index),
      index: index,
      icon: state.currentIndex == index
          ? iconData['activeIcon']!
          : iconData['icon']!,
      isActive: state.currentIndex == index,
      bloc: bloc,
    );
  });
}
