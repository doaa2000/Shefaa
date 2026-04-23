import 'package:flutter/material.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';

class DoctorAvailabilityModel extends DoctorAvailabilityEntity {
  DoctorAvailabilityModel({
    required super.id,
    required super.doctorId,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.session,
    required super.isActive,
  });

  factory DoctorAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return DoctorAvailabilityModel(
      id:        map['id'].toString(),
      doctorId:  map['doctor_id'].toString(),
      date:      DateTime.parse(map['date']),
      startTime: map['start_time'] ?? '',   // ✅ "09:00:00"
      endTime:   map['end_time'] ?? '',     // ✅ "09:30:00"
      session:   map['session'] ?? '',      // ✅ "morning" or "evening"
      isActive:  map['is_active'] ?? true,  // ✅
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':         id,
      'doctor_id':  doctorId,
      'date':       date.toIso8601String(),
      'start_time': startTime,
      'end_time':   endTime,
      'session':    session,
      'is_active':  isActive,
    };
  }

  // ✅ Helper: format time for display ("09:00:00" → "09:00 AM")
  String get formattedStartTime => _formatTime(startTime);
  String get formattedEndTime   => _formatTime(endTime);

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour   = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }
}