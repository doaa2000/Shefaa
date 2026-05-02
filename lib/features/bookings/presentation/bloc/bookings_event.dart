

import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
}

class CreateBookingEvent extends BookingEvent {
  final String doctorId;
  final double amount;
  final String paymentMethod;
final DateTime bookedDate;
  final String startTime;
  final String endTime;
  const CreateBookingEvent({
    required this.doctorId,
    required this.amount,
    required this.paymentMethod,  
    required this.bookedDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [doctorId, amount, bookedDate, startTime, endTime];
}

class GetMyBookingsEvent extends BookingEvent {
  const GetMyBookingsEvent();

  @override
  List<Object?> get props => [];
}
