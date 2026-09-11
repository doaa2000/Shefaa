import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final int doctorId;
  final double amount;
  final String paymentMethod;
  final DateTime bookedDate;
  final String session;
  final String startTime;
  final String endTime;

  const CreateBookingEvent({
    required this.doctorId,
    required this.amount,
    required this.paymentMethod,
    required this.bookedDate,
    required this.session,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props =>
      [doctorId, amount, bookedDate, session, startTime, endTime];
}

class GetMyBookingsEvent extends BookingEvent {
  const GetMyBookingsEvent();
}

class CancelBookingEvent extends BookingEvent {
  final int bookingId;
  const CancelBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
