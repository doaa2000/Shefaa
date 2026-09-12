import 'package:shefaa_app/features/doctors/data/models/doctor_model.dart';
import 'package:shefaa_app/features/doctors/data/models/doctor_schedule_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DoctorsRemoteDatasource {
  Future<List<DoctorModel>> getDoctors(int specialtyId);

  /// The doctor's weekly pattern, for the days they hold a session at all.
  Future<List<DoctorScheduleModel>> getWeeklySchedule(int doctorId);
}

class DoctorsRemoteDatasourceImpl implements DoctorsRemoteDatasource {
  final SupabaseClient supabase;

  DoctorsRemoteDatasourceImpl(this.supabase);

  @override
  Future<List<DoctorModel>> getDoctors(int specialtyId) async {
    final response = await supabase
        .from('Doctors')
        .select()
        .eq('specialty_id', specialtyId)
        // A doctor the admin deactivated must not be bookable.
        .eq('status', 'active')
        .order('rating', ascending: false);

    return (response as List).map((e) => DoctorModel.fromMap(e)).toList();
  }

  @override
  Future<List<DoctorScheduleModel>> getWeeklySchedule(int doctorId) async {
    final response = await supabase
        .from('doctor_schedule')
        .select('weekday, session, start_time, end_time, capacity')
        .eq('doctor_id', doctorId)
        .eq('is_active', true)
        .order('weekday')
        .order('start_time');

    return (response as List)
        .map((e) => DoctorScheduleModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
