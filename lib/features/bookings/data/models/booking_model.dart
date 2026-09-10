import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/doctors/data/models/doctor_model.dart';
import 'package:shefaa_app/features/payment/data/models/payment_model.dart';
class BookingModel extends BookingEntity {
  BookingModel({
    required super.id,
    required super.status,
    required super.createdAt,
    required super.bookedDate,
    required super.startTime,
    required super.endTime,
    required super.payment,
    required super.doctor,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id:         map['id'] is String ? int.parse(map['id']) : map['id'],
      status:     map['status'],
      createdAt:  DateTime.parse(map['created_at']),
      bookedDate: DateTime.parse(map['booked_date']), // ✅
      startTime:  map['start_time'],                  // ✅
      endTime:    map['end_time'],                    // ✅
      payment:    PaymentModel.fromMap(map['payments']),
      doctor:     DoctorModel.fromMap(map['doctor']), // ✅
    );
  }
}