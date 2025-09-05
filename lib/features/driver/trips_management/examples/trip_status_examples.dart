// Trip Status Usage Examples
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/driver_trips_bloc.dart';
import '../presentation/bloc/driver_trips_event.dart';
import '../presentation/bloc/driver_trips_state.dart';

class TripStatusExamples extends StatelessWidget {
  const TripStatusExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Status Examples')),
      body: Column(
        children: [
          // Example 1: Load Current Trips (SCHEDULED + STARTED)
          ElevatedButton(
            onPressed: () {
              context.read<DriverTripsBloc>().add(
                    const LoadCurrentTrips('driver_123'),
                  );
            },
            child: const Text('Load Current Trips'),
          ),

          // Example 2: Load Trip History (COMPLETED)
          ElevatedButton(
            onPressed: () {
              context.read<DriverTripsBloc>().add(
                    const LoadTripHistory('driver_123'),
                  );
            },
            child: const Text('Load Trip History'),
          ),

          // Example 3: Load Specific Status
          ElevatedButton(
            onPressed: () {
              context.read<DriverTripsBloc>().add(
                    const LoadTripsByStatus(
                      driverId: 'driver_123',
                      status: 'SCHEDULED',
                    ),
                  );
            },
            child: const Text('Load Scheduled Trips'),
          ),

          // Example 4: Start a Trip
          ElevatedButton(
            onPressed: () {
              context.read<DriverTripsBloc>().add(
                    const UpdateTripStatus(
                      tripId: 'trip_123',
                      status: 'STARTED',
                    ),
                  );
            },
            child: const Text('Start Trip'),
          ),

          // Example 5: Complete a Trip
          ElevatedButton(
            onPressed: () {
              context.read<DriverTripsBloc>().add(
                    const UpdateTripStatus(
                      tripId: 'trip_123',
                      status: 'COMPLETED',
                    ),
                  );
            },
            child: const Text('Complete Trip'),
          ),

          // Status Listener
          Expanded(
            child: BlocBuilder<DriverTripsBloc, DriverTripsState>(
              builder: (context, state) {
                if (state is CurrentTripsLoaded) {
                  return Column(
                    children: [
                      const Text('Current Trips (SCHEDULED + STARTED):'),
                      ...state.trips.map((trip) => ListTile(
                            title: Text(
                                '${trip.fromLocation} → ${trip.toLocation}'),
                            subtitle: Text(
                                'Status: ${trip.status.name.toUpperCase()}'),
                            trailing: _buildActionButton(context, trip),
                          )),
                    ],
                  );
                } else if (state is TripHistoryLoaded) {
                  return Column(
                    children: [
                      const Text('Trip History (COMPLETED):'),
                      ...state.trips.map((trip) => ListTile(
                            title: Text(
                                '${trip.fromLocation} → ${trip.toLocation}'),
                            subtitle: Text(
                                'Status: ${trip.status.name.toUpperCase()}'),
                            trailing: const Icon(Icons.check_circle,
                                color: Colors.green),
                          )),
                    ],
                  );
                } else if (state is TripStarted) {
                  return const Center(
                    child: Text('Trip Started Successfully!',
                        style: TextStyle(color: Colors.blue, fontSize: 18)),
                  );
                } else if (state is TripCompleted) {
                  return const Center(
                    child: Text('Trip Completed Successfully!',
                        style: TextStyle(color: Colors.green, fontSize: 18)),
                  );
                } else if (state is DriverTripsError) {
                  return Center(
                    child: Text('Error: ${state.message}',
                        style: const TextStyle(color: Colors.red)),
                  );
                } else if (state is DriverTripsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(child: Text('No trips loaded'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, trip) {
    if (trip.isScheduled) {
      return ElevatedButton(
        onPressed: () {
          context.read<DriverTripsBloc>().add(
                UpdateTripStatus(tripId: trip.id, status: 'STARTED'),
              );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Start'),
      );
    } else if (trip.isStarted) {
      return ElevatedButton(
        onPressed: () {
          context.read<DriverTripsBloc>().add(
                UpdateTripStatus(tripId: trip.id, status: 'COMPLETED'),
              );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text('Complete'),
      );
    }
    return const SizedBox.shrink();
  }
}

// Status Flow Example
class StatusFlowExample {
  static void demonstrateFlow(BuildContext context) {
    final bloc = context.read<DriverTripsBloc>();

    // 1. Load current trips (shows SCHEDULED trips)
    bloc.add(const LoadCurrentTrips('driver_123'));

    // 2. Driver clicks "Start Trip" on a SCHEDULED trip
    // This changes status from SCHEDULED → STARTED
    bloc.add(const UpdateTripStatus(tripId: 'trip_123', status: 'STARTED'));

    // 3. Trip now shows in current trips with progress and "Complete" button
    // Driver can track progress and manage passengers

    // 4. Driver clicks "Complete Trip" when finished
    // This changes status from STARTED → COMPLETED
    bloc.add(const UpdateTripStatus(tripId: 'trip_123', status: 'COMPLETED'));

    // 5. Trip now appears in Trip History screen
    bloc.add(const LoadTripHistory('driver_123'));
  }
}

// API Status Mapping
class ApiStatusMapping {
  static const Map<String, String> apiToDisplay = {
    'SCHEDULED': 'Ready to Start',
    'STARTED': 'In Progress',
    'COMPLETED': 'Completed',
    'CANCELLED': 'Cancelled',
  };

  static const Map<String, Color> statusColors = {
    'SCHEDULED': Colors.orange,
    'STARTED': Colors.blue,
    'COMPLETED': Colors.green,
    'CANCELLED': Colors.red,
  };

  static const Map<String, IconData> statusIcons = {
    'SCHEDULED': Icons.schedule,
    'STARTED': Icons.directions_bus,
    'COMPLETED': Icons.check_circle,
    'CANCELLED': Icons.cancel,
  };
}
