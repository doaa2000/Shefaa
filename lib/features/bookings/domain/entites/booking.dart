import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/payment/domain/entites/payment.dart';

import 'package:shefaa_app/features/payment/domain/entites/payment.dart';

// booking.dart
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';

class BookingEntity {
  final int id;
  final String status;
  final DateTime createdAt;
  final DateTime bookedDate;  // ✅
  final String startTime;     // ✅
  final String endTime;       // ✅
  final PaymentEntity payment;
  final DoctorEntity doctor;

  BookingEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.bookedDate,
    required this.startTime,
    required this.endTime,
    required this.payment,
    required this.doctor,
  });
}