import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final int doctorId;
  final String paymentMethod;
  final DateTime bookedDate;
  final String session;
  final String startTime;
  final String endTime;

  const CreateBookingEvent({
    required this.doctorId,
    required this.paymentMethod,
    required this.bookedDate,
    required this.session,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props =>
      [doctorId, bookedDate, session, startTime, endTime];
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

/// Rating a visit that happened. Sending it again replaces what was said
/// before rather than adding a second review.
class RateBookingEvent extends BookingEvent {
  final int bookingId;
  final int stars;
  final String? comment;

  const RateBookingEvent({
    required this.bookingId,
    required this.stars,
    this.comment,
  });

  @override
  List<Object?> get props => [bookingId, stars, comment];
}

/// After the cancellation deadline: the booking stands, the doctor is told.
class ReportAbsenceEvent extends BookingEvent {
  final int bookingId;
  const ReportAbsenceEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
