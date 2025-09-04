import 'package:equatable/equatable.dart';
import 'location_point.dart';
import '../../../trips/domain/entities/trip.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class BookingRequest extends Equatable {
  final String id;
  final Trip trip;
  final LocationPoint pickupLocation;
  final LocationPoint dropoffLocation;
  final DateTime bookingDate;
  final DateTime requestedDate;
  final String passengerName;
  final String passengerPhone;
  final String? passengerEmail;
  final String? specialInstructions;
  final BookingStatus status;
  final double totalAmount;
  final double? extraCharges;
  final String paymentMethod;
  final bool requiresSpecialAssistance;
  final int numberOfPassengers;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookingRequest({
    required this.id,
    required this.trip,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.bookingDate,
    required this.requestedDate,
    required this.passengerName,
    required this.passengerPhone,
    this.passengerEmail,
    this.specialInstructions,
    required this.status,
    required this.totalAmount,
    this.extraCharges,
    required this.paymentMethod,
    this.requiresSpecialAssistance = false,
    this.numberOfPassengers = 1,
    required this.createdAt,
    this.updatedAt,
  });

  double get finalAmount => totalAmount + (extraCharges ?? 0);

  bool get canBeCancelled =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  bool get isCompleted => status == BookingStatus.completed;

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending Confirmation';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  BookingRequest copyWith({
    String? id,
    Trip? trip,
    LocationPoint? pickupLocation,
    LocationPoint? dropoffLocation,
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
    return BookingRequest(
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

  @override
  List<Object?> get props => [
        id,
        trip,
        pickupLocation,
        dropoffLocation,
        bookingDate,
        requestedDate,
        passengerName,
        passengerPhone,
        passengerEmail,
        specialInstructions,
        status,
        totalAmount,
        extraCharges,
        paymentMethod,
        requiresSpecialAssistance,
        numberOfPassengers,
        createdAt,
        updatedAt,
      ];
}
