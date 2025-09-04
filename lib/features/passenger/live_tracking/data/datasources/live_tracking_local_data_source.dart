import 'dart:async';
import 'dart:math';
import '../models/live_trip_model.dart';
import '../../../booking/data/models/location_point_model.dart';
import '../../../trips/data/models/trip_model.dart';
import '../../domain/entities/live_trip.dart' as LiveTrackingDomain;

abstract class LiveTrackingLocalDataSource {
  Future<LiveTripModel?> getCurrentTrip(String passengerId);
  Future<List<LiveTripModel>> getMyBookings(String passengerId);
  Future<bool> cancelTrip(String tripId);
  Future<bool> contactDriver(String driverId, String message);
  Stream<LiveTripModel> getTripUpdates(String tripId);
  Future<bool> rateDriver(String tripId, double rating, String? comment);
  Future<bool> reportIssue(String tripId, String issue, String description);
  Future<List<LocationPointModel>> getTripRoute(String tripId);
}

class LiveTrackingLocalDataSourceImpl implements LiveTrackingLocalDataSource {
  // Simulated data storage
  static List<LiveTripModel> _myBookings = [];
  static LiveTripModel? _currentTrip;
  static final Map<String, StreamController<LiveTripModel>> _tripStreams = {};
  static final Random _random = Random();

  @override
  Future<LiveTripModel?> getCurrentTrip(String passengerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return current active trip if exists
    if (_currentTrip?.isActive == true) {
      return _currentTrip;
    }

    // Check for any active trip in bookings
    try {
      return _myBookings.firstWhere(
        (trip) => trip.isActive && trip.passengerName == 'Current User',
        orElse: () => _generateSampleActiveTrip(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<LiveTripModel>> getMyBookings(String passengerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (_myBookings.isEmpty) {
      _myBookings = _generateDummyBookings();
    }

    return List.from(_myBookings);
  }

  @override
  Future<bool> cancelTrip(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final tripIndex = _myBookings.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1 && _myBookings[tripIndex].canCancel) {
      _myBookings[tripIndex] = _myBookings[tripIndex].copyWith(
        status: LiveTrackingDomain.TripStatus.cancelled,
      ) as LiveTripModel;

      if (_currentTrip?.id == tripId) {
        _currentTrip = _myBookings[tripIndex];
      }

      return true;
    }

    return false;
  }

  @override
  Future<bool> contactDriver(String driverId, String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate successful message sending
    return true;
  }

  @override
  Stream<LiveTripModel> getTripUpdates(String tripId) {
    if (!_tripStreams.containsKey(tripId)) {
      _tripStreams[tripId] = StreamController<LiveTripModel>.broadcast();
      _simulateTripUpdates(tripId);
    }

    return _tripStreams[tripId]!.stream;
  }

  @override
  Future<bool> rateDriver(String tripId, double rating, String? comment) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final tripIndex = _myBookings.indexWhere((trip) => trip.id == tripId);
    if (tripIndex != -1 &&
        _myBookings[tripIndex].status ==
            LiveTrackingDomain.TripStatus.completed) {
      // In a real app, this would send the rating to the server
      return true;
    }

    return false;
  }

  @override
  Future<bool> reportIssue(
      String tripId, String issue, String description) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulate successful issue reporting
    return true;
  }

  @override
  Future<List<LocationPointModel>> getTripRoute(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Simulate route points between pickup and dropoff
    return [
      const LocationPointModel(
        id: 'route_1',
        name: 'Starting Point',
        nameAr: 'نقطة البداية',
        latitude: 23.5880,
        longitude: 58.3829,
        address: 'Pickup Location',
        addressAr: 'موقع الصعود',
        type: 'route',
      ),
      const LocationPointModel(
        id: 'route_2',
        name: 'Checkpoint 1',
        nameAr: 'نقطة تفتيش 1',
        latitude: 23.5900,
        longitude: 58.3850,
        address: 'Route Checkpoint',
        addressAr: 'نقطة تفتيش الطريق',
        type: 'route',
      ),
      const LocationPointModel(
        id: 'route_3',
        name: 'Destination',
        nameAr: 'الوجهة',
        latitude: 23.5920,
        longitude: 58.3870,
        address: 'Dropoff Location',
        addressAr: 'موقع النزول',
        type: 'route',
      ),
    ];
  }

  LiveTripModel _generateSampleActiveTrip() {
    final trips = TripModel.getDummyTrips();
    final locations = LocationPointModel.getDummyPopularLocations();
    final drivers = _getDummyDrivers();

    final now = DateTime.now();

    return LiveTripModel(
      id: 'live_trip_current',
      trip: trips.first,
      pickupLocation: locations[0].copyWith(type: 'pickup'),
      dropoffLocation: locations[1].copyWith(type: 'dropoff'),
      currentDriverLocation: locations[0].copyWith(
        id: 'driver_current_location',
        name: 'Driver Current Position',
        nameAr: 'موقع السائق الحالي',
        latitude: locations[0].latitude + 0.001,
        longitude: locations[0].longitude + 0.001,
        type: 'driver',
      ),
      status: LiveTrackingDomain.TripStatus.accepted,
      bookingTime: now.subtract(const Duration(minutes: 10)),
      estimatedArrival: now.add(const Duration(minutes: 8)),
      estimatedDropoff: now.add(const Duration(minutes: 45)),
      driver: drivers.first,
      passengerName: 'Current User',
      passengerPhone: '+968 9123 4567',
      totalAmount: 12.0,
      paymentMethod: 'cash',
      distance: 25.5,
      estimatedDuration: 35,
      specialInstructions: 'Please call when you arrive',
      isSharedRide: false,
    );
  }

  List<LiveTripModel> _generateDummyBookings() {
    final trips = TripModel.getDummyTrips();
    final locations = LocationPointModel.getDummyPopularLocations();
    final drivers = _getDummyDrivers();
    final now = DateTime.now();

    return [
      // Active trip
      LiveTripModel(
        id: 'booking_1',
        trip: trips[0],
        pickupLocation: locations[0].copyWith(type: 'pickup'),
        dropoffLocation: locations[1].copyWith(type: 'dropoff'),
        currentDriverLocation: locations[0].copyWith(
          id: 'driver_location_1',
          latitude: locations[0].latitude + 0.002,
          longitude: locations[0].longitude + 0.002,
          type: 'driver',
        ),
        status: LiveTrackingDomain.TripStatus.driverEnRoute,
        bookingTime: now.subtract(const Duration(minutes: 15)),
        estimatedArrival: now.add(const Duration(minutes: 5)),
        estimatedDropoff: now.add(const Duration(minutes: 40)),
        driver: drivers[0],
        passengerName: 'Current User',
        passengerPhone: '+968 9123 4567',
        totalAmount: 12.0,
        paymentMethod: 'cash',
        distance: 25.5,
        estimatedDuration: 35,
      ),

      // Completed trip
      LiveTripModel(
        id: 'booking_2',
        trip: trips[1],
        pickupLocation: locations[2].copyWith(type: 'pickup'),
        dropoffLocation: locations[3].copyWith(type: 'dropoff'),
        currentDriverLocation: locations[3].copyWith(
          id: 'driver_location_2',
          type: 'driver',
        ),
        status: LiveTrackingDomain.TripStatus.completed,
        bookingTime: now.subtract(const Duration(days: 1)),
        estimatedArrival: now.subtract(const Duration(days: 1, minutes: 30)),
        estimatedDropoff: now.subtract(const Duration(days: 1)),
        driver: drivers[1],
        passengerName: 'Current User',
        passengerPhone: '+968 9123 4567',
        totalAmount: 25.0,
        paymentMethod: 'credit_card',
        distance: 45.2,
        estimatedDuration: 65,
      ),

      // Cancelled trip
      LiveTripModel(
        id: 'booking_3',
        trip: trips[2],
        pickupLocation: locations[4].copyWith(type: 'pickup'),
        dropoffLocation: locations[5].copyWith(type: 'dropoff'),
        currentDriverLocation: locations[4].copyWith(
          id: 'driver_location_3',
          type: 'driver',
        ),
        status: LiveTrackingDomain.TripStatus.cancelled,
        bookingTime: now.subtract(const Duration(days: 2)),
        driver: drivers[2],
        passengerName: 'Current User',
        passengerPhone: '+968 9123 4567',
        totalAmount: 8.0,
        paymentMethod: 'cash',
        distance: 18.3,
        estimatedDuration: 25,
        specialInstructions: 'Cancelled due to weather',
      ),

      // Pending trip
      LiveTripModel(
        id: 'booking_4',
        trip: trips[3],
        pickupLocation: locations[6].copyWith(type: 'pickup'),
        dropoffLocation: locations[7].copyWith(type: 'dropoff'),
        currentDriverLocation: locations[6].copyWith(
          id: 'driver_location_4',
          type: 'driver',
        ),
        status: LiveTrackingDomain.TripStatus.pending,
        bookingTime: now.add(const Duration(hours: 2)),
        estimatedArrival: now.add(const Duration(hours: 2, minutes: 30)),
        estimatedDropoff: now.add(const Duration(hours: 5)),
        driver: null,
        passengerName: 'Current User',
        passengerPhone: '+968 9123 4567',
        totalAmount: 15.0,
        paymentMethod: 'cash',
        distance: 32.1,
        estimatedDuration: 45,
        isSharedRide: true,
        otherPassengersCount: 2,
      ),
    ];
  }

  List<DriverInfoModel> _getDummyDrivers() {
    return [
      const DriverInfoModel(
        id: 'driver_1',
        name: 'Ahmed Al-Rashid',
        nameAr: 'أحمد الراشد',
        phone: '+968 9123 4567',
        profileImage: null,
        vehicleModel: 'Toyota Hiace',
        vehicleColor: 'White',
        licensePlate: 'MST-1234',
        rating: 4.8,
        totalTrips: 245,
        status: LiveTrackingDomain.DriverStatus.onTrip,
        lastSeen: null,
      ),
      const DriverInfoModel(
        id: 'driver_2',
        name: 'Mohammed Al-Kathiri',
        nameAr: 'محمد الكثيري',
        phone: '+968 9234 5678',
        profileImage: null,
        vehicleModel: 'Mercedes Sprinter',
        vehicleColor: 'Silver',
        licensePlate: 'SAL-5678',
        rating: 4.9,
        totalTrips: 189,
        status: LiveTrackingDomain.DriverStatus.available,
        lastSeen: null,
      ),
      const DriverInfoModel(
        id: 'driver_3',
        name: 'Khalid Al-Balushi',
        nameAr: 'خالد البلوشي',
        phone: '+968 9345 6789',
        profileImage: null,
        vehicleModel: 'Nissan Urvan',
        vehicleColor: 'Blue',
        licensePlate: 'SOH-9012',
        rating: 4.6,
        totalTrips: 156,
        status: LiveTrackingDomain.DriverStatus.busy,
        lastSeen: null,
      ),
    ];
  }

  void _simulateTripUpdates(String tripId) async {
    final controller = _tripStreams[tripId]!;
    final trip = _myBookings.firstWhere((t) => t.id == tripId);

    // Simulate trip progression
    final statuses = [
      LiveTrackingDomain.TripStatus.pending,
      LiveTrackingDomain.TripStatus.accepted,
      LiveTrackingDomain.TripStatus.driverEnRoute,
      LiveTrackingDomain.TripStatus.driverArrived,
      LiveTrackingDomain.TripStatus.inProgress,
      LiveTrackingDomain.TripStatus.completed,
    ];

    int currentStatusIndex = statuses.indexOf(trip.status);

    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }

      currentStatusIndex = (currentStatusIndex + 1) % statuses.length;
      final updatedTrip = trip.copyWith(
        status: statuses[currentStatusIndex],
        currentDriverLocation: trip.currentDriverLocation.copyWith(
          latitude: trip.currentDriverLocation.latitude +
              (_random.nextDouble() - 0.5) * 0.001,
          longitude: trip.currentDriverLocation.longitude +
              (_random.nextDouble() - 0.5) * 0.001,
        ),
      ) as LiveTripModel;

      // Update the stored trip
      final tripIndex = _myBookings.indexWhere((t) => t.id == tripId);
      if (tripIndex != -1) {
        _myBookings[tripIndex] = updatedTrip;
      }

      controller.add(updatedTrip);

      // Stop simulation when trip is completed or cancelled
      if (statuses[currentStatusIndex] ==
              LiveTrackingDomain.TripStatus.completed ||
          statuses[currentStatusIndex] ==
              LiveTrackingDomain.TripStatus.cancelled) {
        timer.cancel();
      }
    });
  }

  static void dispose() {
    for (var controller in _tripStreams.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _tripStreams.clear();
  }
}
