// How to use the Driver Trips API in your existing code

import 'package:flutter/material.dart';
import '../data/datasources/driver_trips_remote_data_source.dart';
import '../data/models/api_trip_model.dart';
import '../domain/entities/driver_trip.dart';

/// Example 1: Using the API in a simple function
Future<void> exampleApiUsage() async {
  // Create the remote data source
  final remoteDataSource = DriverTripsRemoteDataSourceImpl();

  try {
    // Example 1: Get completed trips for driver ID 1
    final completedTrips =
        await remoteDataSource.getTripsByDriverAndStatus(1, 'COMPLETED');
    print('Found ${completedTrips.length} completed trips');

    // Example 2: Get current/assigned trips
    final currentTrips = await remoteDataSource.getCurrentTrips(1);
    print('Found ${currentTrips.length} current trips');

    // Example 3: Convert API model to domain entity
    for (final apiTrip in completedTrips) {
      final domainTrip = apiTrip.toDomainEntity();
      print('Trip: ${domainTrip.routeName}');
    }
  } catch (e) {
    print('API Error: $e');
  }
}

/// Example 2: Using in a StatefulWidget
class DriverTripsListWidget extends StatefulWidget {
  final int driverId;

  const DriverTripsListWidget({super.key, required this.driverId});

  @override
  State<DriverTripsListWidget> createState() => _DriverTripsListWidgetState();
}

class _DriverTripsListWidgetState extends State<DriverTripsListWidget> {
  final _remoteDataSource = DriverTripsRemoteDataSourceImpl();
  List<DriverTrip> _trips = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompletedTrips();
  }

  Future<void> _loadCompletedTrips() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load completed trips from your API
      final apiTrips =
          await _remoteDataSource.getCompletedTrips(widget.driverId);

      // Convert to domain entities
      final domainTrips =
          apiTrips.map((trip) => trip.toDomainEntity()).toList();

      setState(() {
        _trips = domainTrips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadCompletedTrips,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final trip = _trips[index];
        return ListTile(
          title: Text(trip.routeName),
          subtitle: Text('${trip.fromLocation} → ${trip.toLocation}'),
          trailing: Text(trip.status.name.toUpperCase()),
        );
      },
    );
  }
}

/// Example 3: Quick test function you can call anywhere
Future<void> testYourApi() async {
  final remoteDataSource = DriverTripsRemoteDataSourceImpl();

  print('🧪 Testing your API...');

  try {
    // This makes the exact API call you mentioned
    final trips =
        await remoteDataSource.getTripsByDriverAndStatus(1, 'COMPLETED');

    print('✅ Success! Found ${trips.length} trips');

    if (trips.isNotEmpty) {
      final firstTrip = trips.first;
      print(
          '📍 First trip: ${firstTrip.from.address} → ${firstTrip.to.address}');
      print('📅 Date: ${firstTrip.tripDate} at ${firstTrip.tripTime}');
      print('🚌 Bus: ${firstTrip.bus.licenseNumber}');
      print('📊 Bookings: ${firstTrip.bookingCount}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// Example 4: Integration with existing repository pattern
class TripsService {
  final DriverTripsRemoteDataSource _remoteDataSource;

  TripsService(this._remoteDataSource);

  /// Get trips with specific status
  Future<List<DriverTrip>> getTripsWithStatus(
      int driverId, String status) async {
    final apiTrips =
        await _remoteDataSource.getTripsByDriverAndStatus(driverId, status);
    return apiTrips.map((trip) => trip.toDomainEntity()).toList();
  }

  /// Get completed trips specifically
  Future<List<DriverTrip>> getCompletedTrips(int driverId) async {
    return getTripsWithStatus(driverId, 'COMPLETED');
  }

  /// Get active trips
  Future<List<DriverTrip>> getActiveTrips(int driverId) async {
    return getTripsWithStatus(driverId, 'ASSIGNED');
  }
}
