import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../domain/entities/driver_trip.dart';
import '../../bloc/driver_trips_bloc.dart';
import '../../bloc/driver_trips_state.dart';

class RouteNavigationScreen extends StatefulWidget {
  const RouteNavigationScreen({super.key});

  @override
  State<RouteNavigationScreen> createState() => _RouteNavigationScreenState();
}

class _RouteNavigationScreenState extends State<RouteNavigationScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DriverTrip? currentTrip;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode, responsive),
            Expanded(
              child: _buildNavigationContent(isDarkMode, responsive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      padding: responsive.padding(20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.grey[900]!, Colors.black]
              : [AppColors.primary.withOpacity(0.05), Colors.white],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: responsive.padding(12, 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
            child: Icon(
              Icons.navigation,
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
                  LocaleKeys.driver_routeNavigationTitle.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primary,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  LocaleKeys.driver_routeNavigationSubtitle.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationContent(bool isDarkMode, ResponsiveUtils responsive) {
    return BlocBuilder<DriverTripsBloc, DriverTripsState>(
      builder: (context, state) {
        if (state is CurrentTripsLoaded) {
          final activeTrip =
              state.trips.where((trip) => trip.isInProgress).firstOrNull;

          if (activeTrip != null) {
            currentTrip = activeTrip;
            return _buildActiveNavigation(activeTrip, isDarkMode, responsive);
          }
        }

        return _buildNoActiveTrip(isDarkMode, responsive);
      },
    );
  }

  Widget _buildNoActiveTrip(bool isDarkMode, ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: responsive.padding(40, 40),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off,
              size: responsive.fontSize(80),
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: responsive.spacing(24)),
          Text(
            LocaleKeys.driver_noActiveTrip.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: responsive.spacing(12)),
          Text(
            LocaleKeys.driver_noActiveTripHint.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(32)),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to current trips tab
              DefaultTabController.of(context).animateTo(0);
            },
            icon: const Icon(Icons.assignment),
            label: Text(LocaleKeys.driver_viewCurrentTrips.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: responsive.padding(16, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.spacing(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveNavigation(
    DriverTrip trip,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return SingleChildScrollView(
      padding: responsive.padding(20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Overview Card
          _buildTripOverviewCard(trip, isDarkMode, responsive),

          SizedBox(height: responsive.spacing(20)),

          // Route Map Placeholder
          _buildRouteMapCard(trip, isDarkMode, responsive),

          SizedBox(height: responsive.spacing(20)),

          // Current Destination Card
          if (trip.currentDestination != null)
            _buildCurrentDestinationCard(trip, isDarkMode, responsive),

          SizedBox(height: responsive.spacing(20)),

          // Navigation Instructions
          _buildNavigationInstructions(trip, isDarkMode, responsive),

          SizedBox(height: responsive.spacing(20)),

          // Passenger Stops
          _buildPassengerStops(trip, isDarkMode, responsive),
        ],
      ),
    );
  }

  Widget _buildTripOverviewCard(
    DriverTrip trip,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: responsive.padding(10, 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(10)),
                ),
                child: Icon(
                  Icons.route,
                  color: AppColors.primary,
                  size: responsive.fontSize(24),
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.routeName,
                      style: TextStyle(
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      '${trip.fromLocation} → ${trip.toLocation}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(12),
                  vertical: responsive.spacing(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_bus,
                      color: Colors.green,
                      size: responsive.fontSize(16),
                    ),
                    SizedBox(width: responsive.spacing(4)),
                    Text(
                      LocaleKeys.driver_active.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  LocaleKeys.driver_distance.tr(),
                  '${trip.totalDistance.toStringAsFixed(1)} km',
                  Icons.straighten,
                  isDarkMode,
                  responsive,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  LocaleKeys.trips_duration.tr(),
                  '${trip.estimatedDuration} min',
                  Icons.schedule,
                  isDarkMode,
                  responsive,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  LocaleKeys.busBooking_stops.tr(),
                  '${trip.passengers.length}',
                  Icons.location_on,
                  isDarkMode,
                  responsive,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  LocaleKeys.driver_bus.tr(),
                  trip.busNumber,
                  Icons.directions_bus,
                  isDarkMode,
                  responsive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: responsive.fontSize(20),
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(10),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteMapCard(
    DriverTrip trip,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      height: responsive.spacing(250),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        child: Stack(
          children: [
            // Map placeholder - In real implementation, integrate with Google Maps or similar
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: responsive.fontSize(60),
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    SizedBox(height: responsive.spacing(8)),
                    Text(
                      LocaleKeys.driver_interactiveMap.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(16),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      LocaleKeys.driver_mapIntegrationSoon.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Map overlay controls
            Positioned(
              top: responsive.spacing(16),
              right: responsive.spacing(16),
              child: Column(
                children: [
                  _buildMapButton(
                    Icons.my_location,
                    LocaleKeys.driver_map_centerOnBus.tr(),
                    isDarkMode,
                    responsive,
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  _buildMapButton(
                    Icons.fullscreen,
                    LocaleKeys.driver_map_fullScreen.tr(),
                    isDarkMode,
                    responsive,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton(
    IconData icon,
    String tooltip,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tooltip)),
          );
        },
        icon: Icon(
          icon,
          color: AppColors.primary,
          size: responsive.fontSize(20),
        ),
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildCurrentDestinationCard(
    DriverTrip trip,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: responsive.padding(12, 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
            child: Icon(
              Icons.navigation,
              color: Colors.white,
              size: responsive.fontSize(24),
            ),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.driver_nextDestination.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(12),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  trip.currentDestination!,
                  style: TextStyle(
                    fontSize: responsive.fontSize(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: responsive.fontSize(16),
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                    SizedBox(width: responsive.spacing(4)),
                    Text(
                      '${LocaleKeys.driver_eta.tr()}: ${_getEstimatedArrival()}',
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _openExternalNavigation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.spacing(8)),
              ),
            ),
            child: Text(LocaleKeys.common_navigate.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationInstructions(
    DriverTrip trip,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                LocaleKeys.driver_navigationInstructions.tr(),
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),

          // Mock navigation instructions
          _buildInstruction(
            '1. ${LocaleKeys.driver_navigation_stepContinueStraight.tr()}',
            Icons.straight,
            isDarkMode,
            responsive,
          ),
          _buildInstruction(
            '2. ${LocaleKeys.driver_navigation_stepTurnRightAtTrafficLight.tr()}',
            Icons.turn_right,
            isDarkMode,
            responsive,
          ),
          _buildInstruction(
            '3. ${LocaleKeys.driver_navigation_stepMergeOntoHighway.tr()}',
            Icons.merge_type,
            isDarkMode,
            responsive,
          ),
          _buildInstruction(
            '4. ${LocaleKeys.driver_navigation_stepTakeExitToward.tr(namedArgs: {
                  'destination': trip.currentDestination ?? 'destination'
                })}',
            Icons.exit_to_app,
            isDarkMode,
            responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(
    String instruction,
    IconData icon,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing(12)),
      child: Row(
        children: [
          Container(
            padding: responsive.padding(8, 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(8)),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: responsive.fontSize(18),
            ),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerStops(
    DriverTrip trip,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    final waitingPassengers =
        trip.passengers.where((p) => p.isWaiting).toList();

    if (waitingPassengers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                LocaleKeys.driver_upcomingStops.tr(),
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(8),
                  vertical: responsive.spacing(4),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.spacing(12)),
                ),
                child: Text(
                  LocaleKeys.driver_stopsCount.tr(namedArgs: {
                    'count': waitingPassengers.length.toString()
                  }),
                  style: TextStyle(
                    fontSize: responsive.fontSize(10),
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          ...waitingPassengers.take(3).map(
                (passenger) => _buildStopItem(passenger.pickupLocation,
                    passenger.name, isDarkMode, responsive),
              ),
          if (waitingPassengers.length > 3) ...[
            SizedBox(height: responsive.spacing(8)),
            Center(
              child: Text(
                LocaleKeys.driver_moreStops.tr(namedArgs: {
                  'count': (waitingPassengers.length - 3).toString()
                }),
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStopItem(
    String location,
    String passengerName,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing(12)),
      child: Row(
        children: [
          Container(
            width: responsive.spacing(8),
            height: responsive.spacing(8),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  LocaleKeys.driver_pickupLabel
                      .tr(namedArgs: {'name': passengerName}),
                  style: TextStyle(
                    fontSize: responsive.fontSize(12),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  String _getEstimatedArrival() {
    final now = DateTime.now();
    final eta = now.add(const Duration(minutes: 15)); // Mock ETA
    return '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';
  }

  void _openExternalNavigation() {
    // In real implementation, open Google Maps or similar navigation app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.driver_openingNavigation.tr()),
        backgroundColor: Colors.green,
      ),
    );
  }
}
