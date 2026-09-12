import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/doctors/data/models/doctor_model.dart';
import 'package:shefaa_app/features/payment/data/models/payment_model.dart';
import 'package:shefaa_app/features/payment/domain/entites/payment.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.status,
    required super.createdAt,
    required super.bookedDate,
    required super.session,
    required super.startTime,
    required super.endTime,
    required super.payment,
    required super.doctor,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final payment = map['payments'];

    return BookingModel(
      id: map['id'] is String ? int.parse(map['id'] as String) : map['id'] as int,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['created_at'] as String),
      bookedDate: DateTime.parse(map['booked_date'] as String),
      session: map['session'] as String? ?? 'morning',
      startTime: map['start_time'] as String? ?? '',
      endTime: map['end_time'] as String? ?? '',
      // A booking can exist without a payment row; the old code assumed one and
      // threw while parsing the list.
      payment: payment == null
          ? const PaymentEntity(
              id: 0, amount: 0, paymentMethod: 'cash', status: 'pending')
          : PaymentModel.fromMap(payment as Map<String, dynamic>),
      doctor: DoctorModel.fromMap(map['doctor'] as Map<String, dynamic>),
    );
  }
}
