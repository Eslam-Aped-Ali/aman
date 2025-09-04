import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../domain/entities/driver_trip.dart';
import '../../bloc/driver_trips_bloc.dart';
import '../../bloc/driver_trips_event.dart';
import '../../bloc/driver_trips_state.dart';
import '../../../../../shared_fetaures/layout/presentation/navigationController/navigation_bloc.dart';
import '../../../../../shared_fetaures/layout/presentation/navigationController/navigation_event.dart';
import '../widgets/current_trips_header.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/trip_card.dart';

class CurrentTripsScreen extends StatefulWidget {
  const CurrentTripsScreen({super.key});

  @override
  State<CurrentTripsScreen> createState() => _CurrentTripsScreenState();
}

class _CurrentTripsScreenState extends State<CurrentTripsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCurrentTrips();
  }

  void _loadCurrentTrips() {
    // Using dummy driver ID for now - in real app, get from auth/profile
    context.read<DriverTripsBloc>().add(const LoadCurrentTrips('driver_123'));
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
            CurrentTripsHeader(onRefresh: _loadCurrentTrips),
            Expanded(
              child: _buildTripsContent(isDarkMode, responsive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsContent(bool isDarkMode, ResponsiveUtils responsive) {
    return BlocBuilder<DriverTripsBloc, DriverTripsState>(
      builder: (context, state) {
        if (state is DriverTripsLoading) {
          return const LoadingStateWidget(message: 'Loading trips...');
        } else if (state is DriverTripsError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: _loadCurrentTrips,
          );
        } else if (state is DriverTripsEmpty) {
          return EmptyStateWidget(
            message: state.message,
            onRefresh: _loadCurrentTrips,
          );
        } else if (state is CurrentTripsLoaded) {
          return _buildTripsList(state.trips, isDarkMode, responsive);
        }
        return EmptyStateWidget(
          message: 'No trips assigned yet',
          onRefresh: _loadCurrentTrips,
        );
      },
    );
  }

  Widget _buildTripsList(
    List<DriverTrip> trips,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _loadCurrentTrips(),
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
          return TripCard(
            trip: trip,
            onStartTrip: () => _startTrip(trip),
            onCompleteTrip: () => _completeTrip(trip),
            onViewPassengers: () => _viewPassengers(trip),
          );
        },
      ),
    );
  }

  void _startTrip(DriverTrip trip) {
    context.read<DriverTripsBloc>().add(StartTrip(trip.id));
  }

  void _completeTrip(DriverTrip trip) {
    context.read<DriverTripsBloc>().add(CompleteTrip(trip.id));
  }

  void _viewPassengers(DriverTrip trip) {
    // Navigate to passengers screen and load trip passengers
    context.read<DriverTripsBloc>().add(LoadTripPassengers(trip.id));

    // Navigate to index 2 (TripPassengersScreen) using NavigationBloc
    context.read<NavigationBloc>().add(NavigateToPage(2));
  }
}
