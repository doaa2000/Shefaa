import 'package:shefaa_app/features/doctors/data/models/doctor_model.dart';
import 'package:shefaa_app/features/doctors/data/models/doctor_schedule_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DoctorsRemoteDatasource {
  Future<List<DoctorModel>> getDoctors(int specialtyId);

  /// Doctors whose name or specialty contains [query].
  Future<List<DoctorModel>> searchDoctors(String query);

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
  Future<List<DoctorModel>> searchDoctors(String query) async {
    // PostgREST reads `or` as a comma separated list, and % and _ are ilike
    // wildcards. A patient typing any of them would either break the filter or
    // quietly match everything, so they are stripped rather than escaped.
    final term = query.replaceAll(RegExp(r'[,()%_*]'), ' ').trim();
    if (term.isEmpty) return const [];

    final response = await supabase
        .from('Doctors')
        .select()
        .eq('status', 'active')
        .or('name.ilike.%$term%,specialization.ilike.%$term%')
        .order('rating', ascending: false)
        .limit(30);

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
