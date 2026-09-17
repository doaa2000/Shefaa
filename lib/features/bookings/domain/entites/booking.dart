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

  /// When the patient said they would not be coming, after cancelling had
  /// closed. Null for almost every booking, and the reason the button that
  /// says it is not offered twice.
  final DateTime? absenceReportedAt;

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
    this.absenceReportedAt,
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

  bool get absenceReported => absenceReportedAt != null;

  /// The window where cancelling has closed but the appointment has not
  /// started: too late to give the place back, still early enough for the
  /// doctor to do something about an empty chair.
  ///
  /// Asked here so the button is gone before it is pressed rather than an
  /// error after. The database decides it again, and refuses a late one.
  bool get canReportAbsence {
    if (!isUpcoming || canCancel || absenceReported) return false;

    final parts = startTime.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final starts = DateTime(
      bookedDate.year,
      bookedDate.month,
      bookedDate.day,
      hour,
      minute,
    );

    return DateTime.now().isBefore(starts);
  }
}
