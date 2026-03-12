import 'package:flutter/material.dart';
import 'package:shefaa_app/features/doctor_availability/domain/entities/doctor_availability.dart';

class DoctorAvailabilityModel extends DoctorAvailabilityEntity {
  DoctorAvailabilityModel({
    required super.id,
    required super.doctorId,
    required super.date,
    required super.morningHours, required super.eveningHours,
  });

  factory DoctorAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return DoctorAvailabilityModel(
      id: map['id'].toString(),
      doctorId: map['doctor_id'].toString(),
      date: DateTime.parse(map['date']),
    
      morningHours: List<int>.from(map['morning_hours'] ?? []),
      eveningHours: List<int>.from(map['evening_hours'] ?? []
    ));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'date': date.toIso8601String(),
     
      'morning_hours': morningHours,
      'evening_hours': eveningHours,
    };
  }
}