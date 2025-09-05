import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../domain/entities/driver_trip.dart';
import '../../bloc/driver_trips_bloc.dart';
import '../../bloc/driver_trips_event.dart';
import '../../bloc/driver_trips_state.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTripHistory();
  }

  void _loadTripHistory() {
    // Using dummy driver ID for now - in real app, get from auth/profile
    // This will now load COMPLETED trips via API
    context.read<DriverTripsBloc>().add(const LoadTripHistory('driver_123'));
  }

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
              child: _buildHistoryContent(isDarkMode, responsive),
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
              Icons.history,
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
                  'Trip History',
                  style: TextStyle(
                    fontSize: responsive.fontSize(22),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primary,
                  ),
                ),
                SizedBox(height: responsive.spacing(4)),
                Text(
                  'View your completed and cancelled trips',
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadTripHistory,
            icon: Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: responsive.fontSize(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(bool isDarkMode, ResponsiveUtils responsive) {
    return BlocBuilder<DriverTripsBloc, DriverTripsState>(
      builder: (context, state) {
        if (state is DriverTripsLoading) {
          return _buildLoadingState(responsive);
        } else if (state is DriverTripsError) {
          return _buildErrorState(state.message, responsive);
        } else if (state is DriverTripsEmpty) {
          return _buildEmptyState(state.message, responsive);
        } else if (state is TripHistoryLoaded) {
          return _buildHistoryList(state.trips, isDarkMode, responsive);
        }
        return _buildEmptyState('No trip history found', responsive);
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
            'Loading trip history...',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
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
          SizedBox(height: responsive.spacing(16)),
          ElevatedButton(
            onPressed: _loadTripHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, ResponsiveUtils responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: responsive.fontSize(80),
            color: Colors.grey[400],
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
          SizedBox(height: responsive.spacing(16)),
          TextButton(
            onPressed: _loadTripHistory,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    List<DriverTrip> trips,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _loadTripHistory(),
      color: AppColors.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(20),
          vertical: responsive.spacing(16),
        ),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildHistoryCard(trip, isDarkMode, responsive);
        },
      ),
    );
  }

  Widget _buildHistoryCard(
    DriverTrip trip,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(16)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
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
            // Header with route and status
            Row(
              children: [
                Container(
                  padding: responsive.padding(10, 10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(trip.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(10)),
                  ),
                  child: Icon(
                    _getStatusIcon(trip.status),
                    color: _getStatusColor(trip.status),
                    size: responsive.fontSize(22),
                  ),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.fromLocation} → ${trip.toLocation}',
                        style: TextStyle(
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: responsive.spacing(4)),
                      Text(
                        trip.routeName,
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing(8),
                        vertical: responsive.spacing(4),
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(trip.status).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(responsive.spacing(12)),
                      ),
                      child: Text(
                        trip.statusDisplayText,
                        style: TextStyle(
                          fontSize: responsive.fontSize(10),
                          color: _getStatusColor(trip.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(4)),
                    Text(
                      _formatDate(trip.departureTime),
                      style: TextStyle(
                        fontSize: responsive.fontSize(10),
                        color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: responsive.spacing(16)),

            // Trip details row
            Row(
              children: [
                Expanded(
                  child: _buildTripDetail(
                    Icons.schedule,
                    'Departure',
                    _formatTime(trip.departureTime),
                    isDarkMode,
                    responsive,
                  ),
                ),
                Expanded(
                  child: _buildTripDetail(
                    Icons.access_time,
                    trip.actualDepartureTime != null
                        ? 'Actual Start'
                        : 'Scheduled',
                    trip.actualDepartureTime != null
                        ? _formatTime(trip.actualDepartureTime!)
                        : _formatTime(trip.departureTime),
                    isDarkMode,
                    responsive,
                  ),
                ),
                Expanded(
                  child: _buildTripDetail(
                    Icons.people,
                    'Passengers',
                    '${trip.totalPassengers}',
                    isDarkMode,
                    responsive,
                  ),
                ),
                Expanded(
                  child: _buildTripDetail(
                    Icons.directions_bus,
                    'Bus',
                    trip.busNumber,
                    isDarkMode,
                    responsive,
                  ),
                ),
              ],
            ),

            if (trip.isCompleted) ...[
              SizedBox(height: responsive.spacing(12)),
              Divider(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              SizedBox(height: responsive.spacing(12)),

              // Completion statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatistic(
                      'Picked Up',
                      '${trip.pickedUpPassengers}',
                      Colors.blue,
                      isDarkMode,
                      responsive,
                    ),
                  ),
                  Expanded(
                    child: _buildStatistic(
                      'Dropped Off',
                      '${trip.droppedOffPassengers}',
                      Colors.green,
                      isDarkMode,
                      responsive,
                    ),
                  ),
                  Expanded(
                    child: _buildStatistic(
                      'Duration',
                      _calculateActualDuration(trip),
                      AppColors.primary,
                      isDarkMode,
                      responsive,
                    ),
                  ),
                  Expanded(
                    child: _buildStatistic(
                      'Distance',
                      '${trip.totalDistance.toStringAsFixed(1)}km',
                      Colors.orange,
                      isDarkMode,
                      responsive,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: responsive.spacing(16)),

            // Action button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _viewTripDetails(trip),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.spacing(8)),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(fontSize: responsive.fontSize(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(
    IconData icon,
    String label,
    String value,
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
              size: responsive.fontSize(12),
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
            SizedBox(width: responsive.spacing(4)),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistic(
    String label,
    String value,
    Color color,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(10),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: responsive.spacing(4)),
        Row(
          children: [
            Container(
              width: responsive.spacing(3),
              height: responsive.spacing(3),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: responsive.spacing(4)),
            Text(
              value,
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(DriverTripStatus status) {
    switch (status) {
      case DriverTripStatus.scheduled:
        return Colors.orange;
      case DriverTripStatus.started:
        return Colors.blue;
      case DriverTripStatus.completed:
        return Colors.green;
      case DriverTripStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(DriverTripStatus status) {
    switch (status) {
      case DriverTripStatus.scheduled:
        return Icons.schedule;
      case DriverTripStatus.started:
        return Icons.directions_bus;
      case DriverTripStatus.completed:
        return Icons.check_circle;
      case DriverTripStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _calculateActualDuration(DriverTrip trip) {
    if (trip.actualDepartureTime != null && trip.actualArrivalTime != null) {
      final duration =
          trip.actualArrivalTime!.difference(trip.actualDepartureTime!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${minutes}m';
      }
    } else {
      return '${trip.estimatedDuration}m (Est.)';
    }
  }

  void _viewTripDetails(DriverTrip trip) {
    showDialog(
      context: context,
      builder: (context) => _buildTripDetailsDialog(trip, context),
    );
  }

  Widget _buildTripDetailsDialog(DriverTrip trip, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
      ),
      title: Text(
        'Trip Details',
        style: TextStyle(
          fontSize: responsive.fontSize(18),
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Route: ${trip.routeName}',
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: responsive.spacing(8)),
            Text(
              'Description: ${trip.routeDescription}',
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            if (trip.passengers.isNotEmpty) ...[
              Text(
                'Passengers:',
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: responsive.spacing(8)),
              ...trip.passengers.map((passenger) => Padding(
                    padding: EdgeInsets.only(bottom: responsive.spacing(4)),
                    child: Row(
                      children: [
                        Icon(
                          _getPassengerStatusIcon(passenger.status),
                          size: responsive.fontSize(16),
                          color: _getPassengerStatusColor(passenger.status),
                        ),
                        SizedBox(width: responsive.spacing(8)),
                        Expanded(
                          child: Text(
                            passenger.name,
                            style: TextStyle(
                              fontSize: responsive.fontSize(12),
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          _getPassengerStatusText(passenger.status),
                          style: TextStyle(
                            fontSize: responsive.fontSize(10),
                            color: _getPassengerStatusColor(passenger.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  IconData _getPassengerStatusIcon(status) {
    switch (status.toString().split('.').last) {
      case 'waiting':
        return Icons.access_time;
      case 'pickedUp':
        return Icons.directions_walk;
      case 'droppedOff':
        return Icons.check_circle;
      default:
        return Icons.person;
    }
  }

  Color _getPassengerStatusColor(status) {
    switch (status.toString().split('.').last) {
      case 'waiting':
        return Colors.orange;
      case 'pickedUp':
        return Colors.blue;
      case 'droppedOff':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPassengerStatusText(status) {
    switch (status.toString().split('.').last) {
      case 'waiting':
        return 'Waiting';
      case 'pickedUp':
        return 'Picked Up';
      case 'droppedOff':
        return 'Dropped Off';
      default:
        return 'Unknown';
    }
  }
}
