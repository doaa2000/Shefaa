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
  });

  bool get isUpcoming =>
      status == 'confirmed' || status == 'pending';
}
