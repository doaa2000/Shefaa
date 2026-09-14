import 'package:shefaa_app/core/services/booking_policy.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/payment/domain/entites/payment.dart';

class BookingEntity {
  final int id;
  final String status;
  final DateTime createdAt;
  final DateTime bookedDate;

  /// 'morning' or 'evening'.
  final String session;

  /// The window the patient is asked to arrive in.
  ///
  /// There is deliberately no queue number here. The clinic sees people in the
  /// order they walk in, and most of them never booked through the app, so any
  /// position this app computed would be counting the wrong room.
  final String startTime;
  final String endTime;

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
  });

  bool get isUpcoming =>
      status == 'confirmed' || status == 'pending';

  /// The last moment this can still be called off.
  DateTime get cancelDeadline => BookingPolicy.instance
      .deadlineFor(bookedDate: bookedDate, startTime: startTime);

  /// Whether the patient can still cancel it themselves.
  ///
  /// The database decides this too, and refuses a late one. Asking here as
  /// well is not a second opinion: it is so the button is gone before it is
  /// pressed, rather than an error after.
  bool get canCancel =>
      isUpcoming &&
      BookingPolicy.instance
          .canCancel(bookedDate: bookedDate, startTime: startTime);
}
