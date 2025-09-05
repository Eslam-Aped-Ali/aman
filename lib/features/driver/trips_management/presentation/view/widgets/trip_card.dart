import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../domain/entities/driver_trip.dart';

class TripCard extends StatelessWidget {
  final DriverTrip trip;
  final VoidCallback onStartTrip;
  final VoidCallback onCompleteTrip;
  final VoidCallback onViewPassengers;

  const TripCard({
    super.key,
    required this.trip,
    required this.onStartTrip,
    required this.onCompleteTrip,
    required this.onViewPassengers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

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
            _buildTripHeader(isDarkMode, responsive),
            SizedBox(height: responsive.spacing(16)),
            _buildTripDetails(isDarkMode, responsive),
            if (trip.isStarted) ...[
              SizedBox(height: responsive.spacing(16)),
              _buildProgressBar(isDarkMode, responsive),
            ],
            SizedBox(height: responsive.spacing(16)),
            _buildActionButtons(responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHeader(bool isDarkMode, ResponsiveUtils responsive) {
    return Row(
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
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
            color: _getStatusColor(trip.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
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
      ],
    );
  }

  Widget _buildTripDetails(bool isDarkMode, ResponsiveUtils responsive) {
    return Row(
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
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              '${(trip.completionPercentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.spacing(8)),
        LinearProgressIndicator(
          value: trip.completionPercentage,
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ResponsiveUtils responsive) {
    return Row(
      children: [
        if (trip.isScheduled && !trip.isUpcoming) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: onStartTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
              ),
              child: Text(
                'Start Trip',
                style: TextStyle(fontSize: responsive.fontSize(12)),
              ),
            ),
          ),
          SizedBox(width: responsive.spacing(12)),
        ],
        Expanded(
          child: OutlinedButton(
            onPressed: onViewPassengers,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.spacing(8)),
              ),
            ),
            child: Text(
              'View Passengers',
              style: TextStyle(fontSize: responsive.fontSize(12)),
            ),
          ),
        ),
        if (trip.isStarted) ...[
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: ElevatedButton(
              onPressed: onCompleteTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
              ),
              child: Text(
                'Complete',
                style: TextStyle(fontSize: responsive.fontSize(12)),
              ),
            ),
          ),
        ],
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
}
