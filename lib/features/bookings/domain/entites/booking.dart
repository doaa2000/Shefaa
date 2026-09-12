import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/payment/domain/entites/payment.dart';

class BookingEntity {
  final int id;
  final String status;
  final DateTime createdAt;
  final DateTime bookedDate;

  /// 'morning' or 'evening'.
  final String session;

  /// The session window as it stood when the booking was made.
  final String startTime;
  final String endTime;

  /// The patient's place in the queue for this session, computed from the
  /// bookings still standing. Null when it could not be read.
  ///
  /// It can go down when someone ahead cancels, and never up — which is what
  /// the patient is told.
  final int? queueNumber;

  /// The number the doctor is on right now in this session, or null once
  /// everyone has been seen.
  ///
  /// [queueNumber] is a ticket and never moves; this is what moves. Without it
  /// the card could only say "everyone who booked before you", which counts
  /// people the doctor has already finished with.
  final int? nowServing;

  /// How many patients are still in front of this one. Null when either number
  /// is unknown; 0 means it is their turn.
  int? get peopleAhead {
    final mine = queueNumber;
    final serving = nowServing;
    if (mine == null || serving == null) return null;
    final ahead = mine - serving;
    return ahead < 0 ? 0 : ahead;
  }

  /// Their turn: the doctor is on their number.
  bool get isBeingSeen => peopleAhead == 0;

  final PaymentEntity payment;
  final DoctorEntity doctor;

  const BookingEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.bookedDate,
    required this.session,
    required this.startTime,
    required this.endTime,
    required this.payment,
    required this.doctor,
    this.queueNumber,
    this.nowServing,
  });

  bool get isUpcoming =>
      status == 'confirmed' || status == 'pending';
}
