import '../models/driver_trip_model.dart';
import '../models/trip_passenger_model.dart';
import '../../domain/entities/driver_trip.dart';
import '../../domain/entities/trip_passenger.dart';

abstract class DriverTripsLocalDataSource {
  Future<List<DriverTripModel>> getCurrentTrips(String driverId);
  Future<List<DriverTripModel>> getTripHistory(String driverId);
  Future<DriverTripModel?> getTripById(String tripId);
  Future<List<TripPassengerModel>> getTripPassengers(String tripId);
  Future<TripPassengerModel> updatePassengerStatus(
    String tripId,
    String passengerId,
    PassengerStatus status,
  );
  Future<void> notifyPassengerArrival(String passengerId, String message);
  Future<DriverTripModel> startTrip(String tripId);
  Future<DriverTripModel> completeTrip(String tripId);
}

class DriverTripsLocalDataSourceImpl implements DriverTripsLocalDataSource {
  // Dummy data - replace with actual data source later
  static final Map<String, List<DriverTripModel>> _driverTrips = {};
  static final Map<String, DriverTripModel> _allTrips = {};

  static void initializeDummyData(String driverId) {
    if (_driverTrips.containsKey(driverId)) return;

    final now = DateTime.now();

    // Create some dummy passengers
    final List<TripPassengerModel> dummyPassengers1 = [
      TripPassengerModel(
        id: 'passenger_1',
        name: 'Ahmed Ali',
        phoneNumber: '+968 9123 4567',
        pickupLocation: 'Muscat Grand Mall',
        dropoffLocation: 'Seeb Airport',
        pickupTime: now.add(const Duration(hours: 1)),
        status: PassengerStatus.waiting,
      ),
      TripPassengerModel(
        id: 'passenger_2',
        name: 'Fatima Hassan',
        phoneNumber: '+968 9876 5432',
        pickupLocation: 'City Centre Muscat',
        dropoffLocation: 'OAMC Hospital',
        pickupTime: now.add(const Duration(hours: 1, minutes: 15)),
        status: PassengerStatus.waiting,
      ),
      TripPassengerModel(
        id: 'passenger_3',
        name: 'Mohammed Said',
        phoneNumber: '+968 9555 1234',
        pickupLocation: 'Al Qurum Heights',
        dropoffLocation: 'SQU University',
        pickupTime: now.add(const Duration(hours: 1, minutes: 30)),
        status: PassengerStatus.waiting,
      ),
    ];

    final List<TripPassengerModel> dummyPassengers2 = [
      TripPassengerModel(
        id: 'passenger_4',
        name: 'Sara Al-Zahra',
        phoneNumber: '+968 9777 8888',
        pickupLocation: 'Nizwa Souq',
        dropoffLocation: 'Nizwa Hospital',
        pickupTime: now.add(const Duration(days: 1, hours: 2)),
        status: PassengerStatus.waiting,
      ),
      TripPassengerModel(
        id: 'passenger_5',
        name: 'Omar Abdullah',
        phoneNumber: '+968 9333 2222',
        pickupLocation: 'Bahla Fort',
        dropoffLocation: 'Nizwa University',
        pickupTime: now.add(const Duration(days: 1, hours: 2, minutes: 20)),
        status: PassengerStatus.waiting,
      ),
    ];

    // Create current/upcoming trips
    final currentTrips = [
      DriverTripModel(
        id: 'trip_current_1',
        routeName: 'Muscat - Seeb Route',
        fromLocation: 'Muscat',
        toLocation: 'Seeb',
        departureTime: now.add(const Duration(hours: 1)),
        arrivalTime: now.add(const Duration(hours: 2, minutes: 30)),
        status: DriverTripStatus.assigned,
        passengers: dummyPassengers1,
        busNumber: 'BUS-101',
        routeDescription:
            'Express route from Muscat city center to Seeb Airport with multiple stops',
        totalDistance: 45.5,
        estimatedDuration: 90,
        currentDestination: 'Muscat Grand Mall',
        assignedAt: now.subtract(const Duration(hours: 2)),
      ),
      DriverTripModel(
        id: 'trip_upcoming_1',
        routeName: 'Muscat - Nizwa Route',
        fromLocation: 'Muscat',
        toLocation: 'Nizwa',
        departureTime: now.add(const Duration(days: 1, hours: 2)),
        arrivalTime: now.add(const Duration(days: 1, hours: 4)),
        status: DriverTripStatus.assigned,
        passengers: dummyPassengers2,
        busNumber: 'BUS-201',
        routeDescription:
            'Long-distance route from Muscat to Nizwa with scenic mountain views',
        totalDistance: 165.0,
        estimatedDuration: 120,
        currentDestination: 'Nizwa Souq',
        assignedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    // Create trip history
    final historyTrips = [
      DriverTripModel(
        id: 'trip_history_1',
        routeName: 'Salalah - Mirbat Route',
        fromLocation: 'Salalah',
        toLocation: 'Mirbat',
        departureTime: now.subtract(const Duration(days: 3)),
        actualDepartureTime: now
            .subtract(const Duration(days: 3))
            .add(const Duration(minutes: 5)),
        arrivalTime: now
            .subtract(const Duration(days: 3))
            .add(const Duration(hours: 1, minutes: 30)),
        actualArrivalTime: now
            .subtract(const Duration(days: 3))
            .add(const Duration(hours: 1, minutes: 25)),
        status: DriverTripStatus.completed,
        passengers: [
          TripPassengerModel(
            id: 'passenger_h1',
            name: 'Khalid Al-Rashid',
            phoneNumber: '+968 9111 2222',
            pickupLocation: 'Salalah Bus Station',
            dropoffLocation: 'Mirbat Beach Resort',
            pickupTime: now.subtract(const Duration(days: 3)),
            actualPickupTime: now
                .subtract(const Duration(days: 3))
                .add(const Duration(minutes: 10)),
            actualDropoffTime: now
                .subtract(const Duration(days: 3))
                .add(const Duration(hours: 1, minutes: 20)),
            status: PassengerStatus.droppedOff,
          ),
        ],
        busNumber: 'BUS-301',
        routeDescription:
            'Coastal route from Salalah to Mirbat with beach stops',
        totalDistance: 75.0,
        estimatedDuration: 90,
        assignedAt: now.subtract(const Duration(days: 4)),
      ),
      DriverTripModel(
        id: 'trip_history_2',
        routeName: 'Sur - Muscat Route',
        fromLocation: 'Sur',
        toLocation: 'Muscat',
        departureTime: now.subtract(const Duration(days: 7)),
        actualDepartureTime: now.subtract(const Duration(days: 7)),
        arrivalTime:
            now.subtract(const Duration(days: 7)).add(const Duration(hours: 3)),
        actualArrivalTime: now
            .subtract(const Duration(days: 7))
            .add(const Duration(hours: 2, minutes: 55)),
        status: DriverTripStatus.completed,
        passengers: [
          TripPassengerModel(
            id: 'passenger_h2',
            name: 'Amina Al-Balushi',
            phoneNumber: '+968 9444 5555',
            pickupLocation: 'Sur Marina',
            dropoffLocation: 'Muscat International Airport',
            pickupTime: now.subtract(const Duration(days: 7)),
            actualPickupTime: now
                .subtract(const Duration(days: 7))
                .add(const Duration(minutes: 5)),
            actualDropoffTime: now
                .subtract(const Duration(days: 7))
                .add(const Duration(hours: 2, minutes: 50)),
            status: PassengerStatus.droppedOff,
          ),
          TripPassengerModel(
            id: 'passenger_h3',
            name: 'Rashid Al-Hinai',
            phoneNumber: '+968 9666 7777',
            pickupLocation: 'Sur Traditional Market',
            dropoffLocation: 'Muscat Grand Mall',
            pickupTime: now
                .subtract(const Duration(days: 7))
                .add(const Duration(minutes: 20)),
            actualPickupTime: now
                .subtract(const Duration(days: 7))
                .add(const Duration(minutes: 25)),
            actualDropoffTime: now
                .subtract(const Duration(days: 7))
                .add(const Duration(hours: 2, minutes: 40)),
            status: PassengerStatus.droppedOff,
          ),
        ],
        busNumber: 'BUS-401',
        routeDescription:
            'Highway route from Sur to Muscat with express service',
        totalDistance: 200.0,
        estimatedDuration: 180,
        assignedAt: now.subtract(const Duration(days: 8)),
      ),
    ];

    // Store trips
    _driverTrips[driverId] = [...currentTrips, ...historyTrips];

    // Store in all trips map for easy lookup
    for (final trip in [...currentTrips, ...historyTrips]) {
      _allTrips[trip.id] = trip;
    }
  }

  @override
  Future<List<DriverTripModel>> getCurrentTrips(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    initializeDummyData(driverId);

    final trips = _driverTrips[driverId] ?? [];
    return trips
        .where((trip) =>
            trip.status == DriverTripStatus.assigned ||
            trip.status == DriverTripStatus.inProgress)
        .toList();
  }

  @override
  Future<List<DriverTripModel>> getTripHistory(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    initializeDummyData(driverId);

    final trips = _driverTrips[driverId] ?? [];
    return trips
        .where((trip) =>
            trip.status == DriverTripStatus.completed ||
            trip.status == DriverTripStatus.cancelled)
        .toList();
  }

  @override
  Future<DriverTripModel?> getTripById(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _allTrips[tripId];
  }

  @override
  Future<List<TripPassengerModel>> getTripPassengers(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final trip = _allTrips[tripId];
    return trip?.passengers
            .map((p) => TripPassengerModel.fromEntity(p))
            .toList() ??
        [];
  }

  @override
  Future<TripPassengerModel> updatePassengerStatus(
    String tripId,
    String passengerId,
    PassengerStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final trip = _allTrips[tripId];
    if (trip == null) {
      throw Exception('Trip not found');
    }

    final passengerIndex =
        trip.passengers.indexWhere((p) => p.id == passengerId);
    if (passengerIndex == -1) {
      throw Exception('Passenger not found');
    }

    final updatedPassengers = List<TripPassenger>.from(trip.passengers);
    final currentTime = DateTime.now();

    updatedPassengers[passengerIndex] =
        updatedPassengers[passengerIndex].copyWith(
      status: status,
      actualPickupTime: status == PassengerStatus.pickedUp
          ? currentTime
          : updatedPassengers[passengerIndex].actualPickupTime,
      actualDropoffTime: status == PassengerStatus.droppedOff
          ? currentTime
          : updatedPassengers[passengerIndex].actualDropoffTime,
    );

    final updatedTrip = trip.copyWith(passengers: updatedPassengers);
    _allTrips[tripId] = updatedTrip;

    // Update in driver trips list as well
    final driverTrips = _driverTrips.values
        .expand((trips) => trips)
        .where((t) => t.id == tripId);
    if (driverTrips.isNotEmpty) {
      final driverTrip = driverTrips.first;
      final driverId = _driverTrips.keys
          .firstWhere((key) => _driverTrips[key]!.contains(driverTrip));
      final tripIndex =
          _driverTrips[driverId]!.indexWhere((t) => t.id == tripId);
      if (tripIndex != -1) {
        _driverTrips[driverId]![tripIndex] = updatedTrip;
      }
    }

    return TripPassengerModel.fromEntity(updatedPassengers[passengerIndex]);
  }

  @override
  Future<void> notifyPassengerArrival(
      String passengerId, String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate notification service - could integrate with SMS/Push notifications
    print('Notifying passenger $passengerId: $message');
  }

  @override
  Future<DriverTripModel> startTrip(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final trip = _allTrips[tripId];
    if (trip == null) {
      throw Exception('Trip not found');
    }

    final updatedTrip = trip.copyWith(
      status: DriverTripStatus.inProgress,
      actualDepartureTime: DateTime.now(),
    );

    _allTrips[tripId] = updatedTrip;

    // Update in driver trips list as well
    final driverTrips = _driverTrips.values
        .expand((trips) => trips)
        .where((t) => t.id == tripId);
    if (driverTrips.isNotEmpty) {
      final driverTrip = driverTrips.first;
      final driverId = _driverTrips.keys
          .firstWhere((key) => _driverTrips[key]!.contains(driverTrip));
      final tripIndex =
          _driverTrips[driverId]!.indexWhere((t) => t.id == tripId);
      if (tripIndex != -1) {
        _driverTrips[driverId]![tripIndex] = updatedTrip;
      }
    }

    return updatedTrip;
  }

  @override
  Future<DriverTripModel> completeTrip(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final trip = _allTrips[tripId];
    if (trip == null) {
      throw Exception('Trip not found');
    }

    final updatedTrip = trip.copyWith(
      status: DriverTripStatus.completed,
      actualArrivalTime: DateTime.now(),
    );

    _allTrips[tripId] = updatedTrip;

    // Update in driver trips list as well
    final driverTrips = _driverTrips.values
        .expand((trips) => trips)
        .where((t) => t.id == tripId);
    if (driverTrips.isNotEmpty) {
      final driverTrip = driverTrips.first;
      final driverId = _driverTrips.keys
          .firstWhere((key) => _driverTrips[key]!.contains(driverTrip));
      final tripIndex =
          _driverTrips[driverId]!.indexWhere((t) => t.id == tripId);
      if (tripIndex != -1) {
        _driverTrips[driverId]![tripIndex] = updatedTrip;
      }
    }

    return updatedTrip;
  }
}
