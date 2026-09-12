import 'package:shefaa_app/features/doctors/data/models/doctor_model.dart';
import 'package:shefaa_app/features/doctors/data/models/doctor_schedule_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DoctorsRemoteDatasource {
  /// [cityId] null means every city -- the patient has not picked one.
  Future<List<DoctorModel>> getDoctors(int specialtyId, {int? cityId});

  /// Doctors whose name or specialty contains [query].
  Future<List<DoctorModel>> searchDoctors(String query, {int? cityId});

  /// The doctor's weekly pattern, for the days they hold a session at all.
  Future<List<DoctorScheduleModel>> getWeeklySchedule(int doctorId);
}

class DoctorsRemoteDatasourceImpl implements DoctorsRemoteDatasource {
  final SupabaseClient supabase;

  DoctorsRemoteDatasourceImpl(this.supabase);

  /// The clinics in one city.
  ///
  /// A doctor's city is two tables away -- Doctors.clinic_id -> Clinics.city_id
  /// -- so the clinics are fetched first and the doctors filtered by them. The
  /// alternative, an embedded PostgREST filter, only works while the foreign
  /// key metadata is exactly right, and this database has been rebuilt by hand
  /// more than once.
  Future<List<int>> _clinicIdsIn(int cityId) async {
    final response =
        await supabase.from('Clinics').select('id').eq('city_id', cityId);

    return (response as List)
        .map((e) => ((e as Map<String, dynamic>)['id'] as num).toInt())
        .toList();
  }

  @override
  Future<List<DoctorModel>> getDoctors(int specialtyId, {int? cityId}) async {
    List<int>? clinicIds;
    if (cityId != null) {
      clinicIds = await _clinicIdsIn(cityId);
      // A city with no clinics has no doctors. Asking anyway would return every
      // doctor, because an empty `in` list is not a filter.
      if (clinicIds.isEmpty) return const [];
    }

    var query = supabase
        .from('Doctors')
        .select()
        .eq('specialty_id', specialtyId)
        // A doctor the admin deactivated must not be bookable.
        .eq('status', 'active');

    if (clinicIds != null) {
      query = query.inFilter('clinic_id', clinicIds);
    }

    final response = await query.order('rating', ascending: false);

    return (response as List).map((e) => DoctorModel.fromMap(e)).toList();
  }

  @override
  Future<List<DoctorModel>> searchDoctors(String query, {int? cityId}) async {
    // PostgREST reads `or` as a comma separated list, and % and _ are ilike
    // wildcards. A patient typing any of them would either break the filter or
    // quietly match everything, so they are stripped rather than escaped.
    final term = query.replaceAll(RegExp(r'[,()%_*]'), ' ').trim();
    if (term.isEmpty) return const [];

    List<int>? clinicIds;
    if (cityId != null) {
      clinicIds = await _clinicIdsIn(cityId);
      if (clinicIds.isEmpty) return const [];
    }

    var request = supabase
        .from('Doctors')
        .select()
        .eq('status', 'active')
        .or('name.ilike.%$term%,specialization.ilike.%$term%');

    if (clinicIds != null) {
      request = request.inFilter('clinic_id', clinicIds);
    }

    final response =
        await request.order('rating', ascending: false).limit(30);

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
