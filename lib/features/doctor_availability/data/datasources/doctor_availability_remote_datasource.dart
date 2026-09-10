import 'dart:developer';

import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_details_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DoctorAvailabilityRemoteDatasource {
  Future<DoctorDetailsModel> getDoctorAvailability(int doctorId, DateTime date);
}

class DoctorAvailabilityRemoteDatasourceImpl
    implements DoctorAvailabilityRemoteDatasource {
  final SupabaseClient supabase;

  DoctorAvailabilityRemoteDatasourceImpl(this.supabase);

  @override
  Future<DoctorDetailsModel> getDoctorAvailability(int doctorId, DateTime date) async {
    final String formattedDate = date.toIso8601String().split('T')[0]; // "2026-04-25"

    final data = await supabase
        .from('Doctors')
        .select('''
          id,
          name,
          specialization,
          image,
          consultation_fee,
          rating,
          specialty_id,
          clinic_id,
          waiting_time,
          location,
          doctor_availability (
            id,
            doctor_id,
            date,
            start_time,
            end_time,
            session,
            is_active
          )
        ''')
        .eq('id', doctorId)
        .eq('doctor_availability.date', formattedDate)        // ✅ filter by selected date
        .eq('doctor_availability.is_active', true)            // ✅ only active slots
        .single();

    return DoctorDetailsModel.fromMap(data);
  }
}