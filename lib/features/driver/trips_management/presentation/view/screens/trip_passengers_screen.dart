import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../generated/locale_keys.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../domain/entities/trip_passenger.dart';
import '../../bloc/driver_trips_bloc.dart';
import '../../bloc/driver_trips_event.dart';
import '../../bloc/driver_trips_state.dart';

class TripPassengersScreen extends StatefulWidget {
  const TripPassengersScreen({super.key});

  @override
  State<TripPassengersScreen> createState() => _TripPassengersScreenState();
}

class _TripPassengersScreenState extends State<TripPassengersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? currentTripId;

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
              child: _buildPassengersContent(isDarkMode, responsive),
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
              Icons.people,
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
                  LocaleKeys.driver_tripPassengers.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primary,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  LocaleKeys.driver_managePassengersDescription.tr(),
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

  Widget _buildPassengersContent(bool isDarkMode, ResponsiveUtils responsive) {
    return BlocConsumer<DriverTripsBloc, DriverTripsState>(
      listener: (context, state) {
        if (state is TripPassengersLoaded) {
          currentTripId = state.tripId;
        } else if (state is PassengerStatusUpdated) {
          _showStatusUpdateSnackBar(state.passenger);
        } else if (state is PassengerNotified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is DriverTripsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DriverTripsLoading) {
          return _buildLoadingState(responsive);
        } else if (state is TripPassengersLoaded) {
          return _buildPassengersList(state.passengers, isDarkMode, responsive);
        } else if (state is DriverTripsError) {
          return _buildErrorState(state.message, responsive);
        }
        return _buildSelectTripState(responsive);
      },
    );
  }

  Widget _buildLoadingState(ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: responsive.fontSize(50),
            height: responsive.fontSize(50),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            LocaleKeys.driver_loadingPassengers.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectTripState(ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: responsive.fontSize(80),
            color: Colors.grey[400],
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            LocaleKeys.driver_selectTripToViewPassengers.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            LocaleKeys.driver_goToCurrentTripsHint.tr(),
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: responsive.fontSize(80),
            color: Colors.red[400],
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            message,
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersList(
    List<TripPassenger> passengers,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        if (currentTripId != null) {
          context
              .read<DriverTripsBloc>()
              .add(LoadTripPassengers(currentTripId!));
        }
      },
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(20),
          vertical: responsive.spacing(16),
        ),
        itemCount: passengers.length,
        itemBuilder: (context, index) {
          final passenger = passengers[index];
          return _buildPassengerCard(passenger, isDarkMode, responsive);
        },
      ),
    );
  }

  Widget _buildPassengerCard(
    TripPassenger passenger,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(16)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(
          color: _getStatusColor(passenger.status).withOpacity(0.3),
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
      child: Padding(
        padding: responsive.padding(16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                Container(
                  padding: responsive.padding(10, 10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(passenger.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(10)),
                  ),
                  child: Icon(
                    _getStatusIcon(passenger.status),
                    color: _getStatusColor(passenger.status),
                    size: responsive.fontSize(22),
                  ),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger.name,
                        style: TextStyle(
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: responsive.spacing(4)),
                      Text(
                        passenger.phoneNumber,
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(8),
                    vertical: responsive.spacing(4),
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(passenger.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(12)),
                  ),
                  child: Text(
                    _getStatusDisplayText(passenger.status),
                    style: TextStyle(
                      fontSize: responsive.fontSize(10),
                      color: _getStatusColor(passenger.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: responsive.spacing(16)),

            // Location details
            _buildLocationDetail(
              LocaleKeys.booking_pickupLocation.tr(),
              passenger.pickupLocation,
              Icons.location_on,
              Colors.green,
              isDarkMode,
              responsive,
            ),

            SizedBox(height: responsive.spacing(8)),

            _buildLocationDetail(
              LocaleKeys.booking_dropoffLocation.tr(),
              passenger.dropoffLocation,
              Icons.location_off,
              Colors.red,
              isDarkMode,
              responsive,
            ),

            SizedBox(height: responsive.spacing(16)),

            // Time details
            Row(
              children: [
                Expanded(
                  child: _buildTimeDetail(
                    LocaleKeys.driver_time_scheduled.tr(),
                    _formatTime(passenger.pickupTime),
                    Icons.schedule,
                    isDarkMode,
                    responsive,
                  ),
                ),
                if (passenger.actualPickupTime != null)
                  Expanded(
                    child: _buildTimeDetail(
                      LocaleKeys.driver_time_pickedUp.tr(),
                      _formatTime(passenger.actualPickupTime!),
                      Icons.check_circle,
                      isDarkMode,
                      responsive,
                    ),
                  ),
                if (passenger.actualDropoffTime != null)
                  Expanded(
                    child: _buildTimeDetail(
                      LocaleKeys.driver_time_droppedOff.tr(),
                      _formatTime(passenger.actualDropoffTime!),
                      Icons.done_all,
                      isDarkMode,
                      responsive,
                    ),
                  ),
              ],
            ),

            SizedBox(height: responsive.spacing(16)),

            Divider(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),

            SizedBox(height: responsive.spacing(16)),

            // Action buttons
            _buildActionButtons(passenger, isDarkMode, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetail(
    String label,
    String location,
    IconData icon,
    Color color,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: responsive.fontSize(16),
        ),
        SizedBox(width: responsive.spacing(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              Text(
                location,
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDetail(
    String label,
    String time,
    IconData icon,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: responsive.fontSize(14),
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
            SizedBox(width: responsive.spacing(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          time,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    TripPassenger passenger,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Row(
      children: [
        // Pickup/Drop-off button
        if (passenger.isWaiting) ...[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _updatePassengerStatus(
                passenger,
                PassengerStatus.pickedUp,
              ),
              icon: const Icon(Icons.directions_walk, size: 16),
              label: Text(LocaleKeys.driver_pickUp.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
              ),
            ),
          ),
        ] else if (passenger.isPickedUp) ...[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _updatePassengerStatus(
                passenger,
                PassengerStatus.droppedOff,
              ),
              icon: const Icon(Icons.location_off, size: 16),
              label: Text(LocaleKeys.driver_dropOff.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            flex: 2,
            child: Container(
              padding: responsive.padding(12, 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.spacing(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: responsive.fontSize(16),
                  ),
                  SizedBox(width: responsive.spacing(4)),
                  Text(
                    LocaleKeys.booking_status_completed.tr(),
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        SizedBox(width: responsive.spacing(8)),

        // Arrived notification button
        if (passenger.isWaiting) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _notifyArrival(passenger),
              icon: const Icon(Icons.notifications, size: 16),
              label: Text(LocaleKeys.driver_arrived.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
              ),
            ),
          ),
        ],

        // Call button
        SizedBox(width: responsive.spacing(8)),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive.spacing(8)),
          ),
          child: IconButton(
            onPressed: () => _callPassenger(passenger),
            icon: const Icon(Icons.phone, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.waiting:
        return Colors.orange;
      case PassengerStatus.pickedUp:
        return Colors.blue;
      case PassengerStatus.droppedOff:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.waiting:
        return Icons.access_time;
      case PassengerStatus.pickedUp:
        return Icons.directions_walk;
      case PassengerStatus.droppedOff:
        return Icons.check_circle;
    }
  }

  String _getStatusDisplayText(PassengerStatus status) {
    switch (status) {
      case PassengerStatus.waiting:
        return LocaleKeys.driver_statusText_waiting.tr();
      case PassengerStatus.pickedUp:
        return LocaleKeys.driver_statusText_onBoard.tr();
      case PassengerStatus.droppedOff:
        return LocaleKeys.driver_statusText_droppedOff.tr();
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _updatePassengerStatus(TripPassenger passenger, PassengerStatus status) {
    if (currentTripId != null) {
      context.read<DriverTripsBloc>().add(
            UpdatePassengerStatus(
              tripId: currentTripId!,
              passengerId: passenger.id,
              status: status,
            ),
          );
    }
  }

  void _notifyArrival(TripPassenger passenger) {
    final message = LocaleKeys.driver_notifyArrivalMessage.tr(namedArgs: {
      'name': passenger.name,
      'location': passenger.pickupLocation,
    });

    context.read<DriverTripsBloc>().add(
          NotifyPassengerArrival(
            passengerId: passenger.id,
            message: message,
          ),
        );
  }

  void _callPassenger(TripPassenger passenger) {
    // This will open the phone dialer with the passenger's number
    // In real implementation, you might want to use url_launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.driver_callingNumber
            .tr(namedArgs: {'number': passenger.phoneNumber})),
        action: SnackBarAction(
          label: LocaleKeys.liveTracking_call.tr(),
          onPressed: () {
            // Implement actual calling functionality
          },
        ),
      ),
    );
  }

  void _showStatusUpdateSnackBar(TripPassenger passenger) {
    final statusText = _getStatusDisplayText(passenger.status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.driver_statusUpdated.tr(namedArgs: {
          'name': passenger.name,
          'status': statusText,
        })),
        backgroundColor: Colors.green,
      ),
    );
  }
}
