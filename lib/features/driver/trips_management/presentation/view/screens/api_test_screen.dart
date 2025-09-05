import 'package:flutter/material.dart';
import '../../../data/datasources/driver_trips_remote_data_source.dart';
import '../../../data/models/api_trip_model.dart';
import '../../../../../../core/shared/services/driver_trips_api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final _apiService = DriverTripsApiService(DriverTripsRemoteDataSourceImpl());
  List<ApiTripModel> _trips = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserToken();
  }

  void _loadUserToken() async {
    // Set a test token for demonstration
    // Replace with actual user token
    await _apiService.setTestToken('eyj...your_actual_token_here');
  }

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _trips = [];
    });

    try {
      final trips = await _apiService.testApiCall();
      setState(() {
        _trips = trips;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Endpoint Test',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'URL: http://ec2-13-61-182-206.eu-north-1.compute.amazonaws.com/trips/by-driver/1?status=COMPLETED',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Token: ${_apiService.getCurrentToken()?.substring(0, 20) ?? 'Not set'}...',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testApi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Test API Call'),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Error:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        )
                      : _trips.isEmpty
                          ? const Center(
                              child: Text(
                                'No trips loaded yet.\nTap the button to test the API.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _trips.length,
                              itemBuilder: (context, index) {
                                final trip = _trips[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Trip #${trip.id}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                            'From: ${trip.from.address} (${trip.from.cityName})'),
                                        Text(
                                            'To: ${trip.to.address} (${trip.to.cityName})'),
                                        Text(
                                            'Date: ${trip.tripDate} at ${trip.tripTime}'),
                                        Text('Status: ${trip.status}'),
                                        Text('Bus: ${trip.bus.licenseNumber}'),
                                        Text('Bookings: ${trip.bookingCount}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
