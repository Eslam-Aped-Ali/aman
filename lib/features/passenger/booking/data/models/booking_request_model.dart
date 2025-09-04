import '../../domain/entities/booking_request.dart';
import '../../../trips/data/models/trip_model.dart';
import 'location_point_model.dart';

class BookingRequestModel extends BookingRequest {
  const BookingRequestModel({
    required super.id,
    required super.trip,
    required super.pickupLocation,
    required super.dropoffLocation,
    required super.bookingDate,
    required super.requestedDate,
    required super.passengerName,
    required super.passengerPhone,
    super.passengerEmail,
    super.specialInstructions,
    required super.status,
    required super.totalAmount,
    super.extraCharges,
    required super.paymentMethod,
    super.requiresSpecialAssistance = false,
    super.numberOfPassengers = 1,
    required super.createdAt,
    super.updatedAt,
  });

  factory BookingRequestModel.fromEntity(BookingRequest booking) {
    return BookingRequestModel(
      id: booking.id,
      trip: booking.trip,
      pickupLocation: booking.pickupLocation,
      dropoffLocation: booking.dropoffLocation,
      bookingDate: booking.bookingDate,
      requestedDate: booking.requestedDate,
      passengerName: booking.passengerName,
      passengerPhone: booking.passengerPhone,
      passengerEmail: booking.passengerEmail,
      specialInstructions: booking.specialInstructions,
      status: booking.status,
      totalAmount: booking.totalAmount,
      extraCharges: booking.extraCharges,
      paymentMethod: booking.paymentMethod,
      requiresSpecialAssistance: booking.requiresSpecialAssistance,
      numberOfPassengers: booking.numberOfPassengers,
      createdAt: booking.createdAt,
      updatedAt: booking.updatedAt,
    );
  }

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'] as String,
      trip: TripModel.fromJson(json['trip'] as Map<String, dynamic>),
      pickupLocation: LocationPointModel.fromJson(
          json['pickupLocation'] as Map<String, dynamic>),
      dropoffLocation: LocationPointModel.fromJson(
          json['dropoffLocation'] as Map<String, dynamic>),
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      requestedDate: DateTime.parse(json['requestedDate'] as String),
      passengerName: json['passengerName'] as String,
      passengerPhone: json['passengerPhone'] as String,
      passengerEmail: json['passengerEmail'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => BookingStatus.pending,
      ),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      extraCharges: json['extraCharges'] != null
          ? (json['extraCharges'] as num).toDouble()
          : null,
      paymentMethod: json['paymentMethod'] as String,
      requiresSpecialAssistance:
          json['requiresSpecialAssistance'] as bool? ?? false,
      numberOfPassengers: json['numberOfPassengers'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip': (trip as TripModel).toJson(),
      'pickupLocation': (pickupLocation as LocationPointModel).toJson(),
      'dropoffLocation': (dropoffLocation as LocationPointModel).toJson(),
      'bookingDate': bookingDate.toIso8601String(),
      'requestedDate': requestedDate.toIso8601String(),
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerEmail': passengerEmail,
      'specialInstructions': specialInstructions,
      'status': status.name,
      'totalAmount': totalAmount,
      'extraCharges': extraCharges,
      'paymentMethod': paymentMethod,
      'requiresSpecialAssistance': requiresSpecialAssistance,
      'numberOfPassengers': numberOfPassengers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  BookingRequestModel copyWith({
    String? id,
    trip,
    pickupLocation,
    dropoffLocation,
    DateTime? bookingDate,
    DateTime? requestedDate,
    String? passengerName,
    String? passengerPhone,
    String? passengerEmail,
    String? specialInstructions,
    BookingStatus? status,
    double? totalAmount,
    double? extraCharges,
    String? paymentMethod,
    bool? requiresSpecialAssistance,
    int? numberOfPassengers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      trip: trip ?? this.trip,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      bookingDate: bookingDate ?? this.bookingDate,
      requestedDate: requestedDate ?? this.requestedDate,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerEmail: passengerEmail ?? this.passengerEmail,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      extraCharges: extraCharges ?? this.extraCharges,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      requiresSpecialAssistance:
          requiresSpecialAssistance ?? this.requiresSpecialAssistance,
      numberOfPassengers: numberOfPassengers ?? this.numberOfPassengers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Dummy data generator for booking requests
  static List<BookingRequestModel> getDummyBookings() {
    final trips = TripModel.getDummyTrips();
    final locations = LocationPointModel.getDummyPopularLocations();

    return [
      BookingRequestModel(
        id: 'booking_1',
        trip: trips[0],
        pickupLocation: locations[0], // Muscat Airport
        dropoffLocation: locations[6], // Nizwa Fort
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        requestedDate: DateTime.now(),
        passengerName: 'Ahmed Al Rashid',
        passengerPhone: '+96890123456',
        passengerEmail: 'ahmed.alrashid@email.com',
        specialInstructions: 'Please call when you arrive at the airport',
        status: BookingStatus.confirmed,
        totalAmount: 45.0,
        extraCharges: 5.0,
        paymentMethod: 'Cash',
        numberOfPassengers: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      BookingRequestModel(
        id: 'booking_2',
        trip: trips[1],
        pickupLocation: locations[2], // Mutrah Souq
        dropoffLocation: locations[8], // Salalah Airport
        bookingDate: DateTime.now().add(const Duration(days: 3)),
        requestedDate: DateTime.now().subtract(const Duration(hours: 1)),
        passengerName: 'Fatima Al Zahra',
        passengerPhone: '+96891234567',
        specialInstructions: 'Traveling with elderly parent, need assistance',
        status: BookingStatus.pending,
        totalAmount: 120.0,
        paymentMethod: 'Credit Card',
        requiresSpecialAssistance: true,
        numberOfPassengers: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      BookingRequestModel(
        id: 'booking_3',
        trip: trips[2],
        pickupLocation: locations[4], // Al Amerat
        dropoffLocation: locations[11], // Sohar Fort
        bookingDate: DateTime.now().add(const Duration(days: 2)),
        requestedDate: DateTime.now().subtract(const Duration(minutes: 30)),
        passengerName: 'Mohammed Al Kindi',
        passengerPhone: '+96892345678',
        passengerEmail: 'mohammed.kindi@email.com',
        specialInstructions: 'Business trip, need receipt',
        status: BookingStatus.confirmed,
        totalAmount: 75.0,
        extraCharges: 10.0,
        paymentMethod: 'Credit Card',
        numberOfPassengers: 1,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }
}
