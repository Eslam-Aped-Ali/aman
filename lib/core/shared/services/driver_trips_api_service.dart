import '../../../features/driver/trips_management/data/datasources/driver_trips_remote_data_source.dart';
import '../../../features/driver/trips_management/data/models/api_trip_model.dart';
import '../../../features/driver/trips_management/domain/entities/driver_trip.dart';
import 'storage_service.dart';

class DriverTripsApiService {
  final DriverTripsRemoteDataSource _remoteDataSource;

  DriverTripsApiService(this._remoteDataSource);

  /// Get completed trips for a driver
  /// Example: getCompletedTrips(1) to get completed trips for driver ID 1
  Future<List<DriverTrip>> getCompletedTrips(int driverId) async {
    try {
      final apiTrips = await _remoteDataSource.getCompletedTrips(driverId);
      return apiTrips.map((apiTrip) => apiTrip.toDomainEntity()).toList();
    } catch (e) {
      print('Error fetching completed trips: $e');
      rethrow;
    }
  }

  /// Get trips by driver and status
  /// Example: getTripsByStatus(1, 'COMPLETED') to get completed trips for driver ID 1
  Future<List<DriverTrip>> getTripsByStatus(int driverId, String status) async {
    try {
      final apiTrips =
          await _remoteDataSource.getTripsByDriverAndStatus(driverId, status);
      return apiTrips.map((apiTrip) => apiTrip.toDomainEntity()).toList();
    } catch (e) {
      print('Error fetching trips by status: $e');
      rethrow;
    }
  }

  /// Get current/assigned trips for a driver
  Future<List<DriverTrip>> getCurrentTrips(int driverId) async {
    try {
      final apiTrips = await _remoteDataSource.getCurrentTrips(driverId);
      return apiTrips.map((apiTrip) => apiTrip.toDomainEntity()).toList();
    } catch (e) {
      print('Error fetching current trips: $e');
      rethrow;
    }
  }

  /// Get all trips for a driver (regardless of status)
  Future<List<DriverTrip>> getAllDriverTrips(int driverId) async {
    try {
      final apiTrips = await _remoteDataSource.getAllDriverTrips(driverId);
      return apiTrips.map((apiTrip) => apiTrip.toDomainEntity()).toList();
    } catch (e) {
      print('Error fetching all driver trips: $e');
      rethrow;
    }
  }

  /// Helper method to test the API with your exact endpoint
  /// This method makes the exact API call you mentioned
  Future<List<ApiTripModel>> testApiCall() async {
    try {
      // Get current driver ID from storage or use test ID
      const testDriverId = 1;

      // Make the API call to your exact endpoint
      final trips = await _remoteDataSource.getTripsByDriverAndStatus(
          testDriverId, 'COMPLETED');

      print('✅ API call successful!');
      print('🚌 Found ${trips.length} completed trips');

      for (final trip in trips) {
        print('Trip ID: ${trip.id}');
        print('From: ${trip.from.address} (${trip.from.cityName})');
        print('To: ${trip.to.address} (${trip.to.cityName})');
        print('Date: ${trip.tripDate} at ${trip.tripTime}');
        print('Status: ${trip.status}');
        print('Bus: ${trip.bus.licenseNumber}');
        print('Bookings: ${trip.bookingCount}');
        print('---');
      }

      return trips;
    } catch (e) {
      print('❌ API call failed: $e');
      rethrow;
    }
  }

  /// Get current user's auth token for debugging
  String? getCurrentToken() {
    return StorageService.getString('auth_token');
  }

  /// Set auth token for testing
  Future<void> setTestToken(String token) async {
    await StorageService.setString('auth_token', token);
  }
}
