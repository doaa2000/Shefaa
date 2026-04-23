import 'package:flutter/material.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';

// doctor_availability.dart (entity)
class DoctorAvailabilityEntity {
  final String id;
  final String doctorId;
  final DateTime date;
  final String startTime;  // ✅ replaces morningHours
  final String endTime;    // ✅ replaces eveningHours
  final String session;    // ✅ 'morning' or 'evening'
  final bool isActive;     // ✅ new

  DoctorAvailabilityEntity({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.session,
    required this.isActive,
  });
}