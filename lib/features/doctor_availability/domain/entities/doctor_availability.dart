import 'package:flutter/material.dart';

class DoctorAvailabilityEntity {
  final String id;
  final String doctorId;
  final DateTime date;

  final List<int> morningHours;
  final List<int> eveningHours;

  DoctorAvailabilityEntity({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.morningHours,
    required this.eveningHours,
  });
}
