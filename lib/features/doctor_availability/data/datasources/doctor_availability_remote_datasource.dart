import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DoctorAvailabilityRemoteDatasource {
  Future<List<DoctorAvailabilityModel>> getDoctorAvailability(String doctorId);
}

class DoctorAvailabilityRemoteDatasourceImpl
    implements DoctorAvailabilityRemoteDatasource {
  final SupabaseClient supabase;

  DoctorAvailabilityRemoteDatasourceImpl(this.supabase);

  @override
  Future<List<DoctorAvailabilityModel>> getDoctorAvailability(
    String doctorId,
  ) async {
    final data = await supabase
        .from('doctor_availability')
        .select()
        .eq('doctor_id', doctorId)
        .order('date', ascending: true);

    return (data as List<dynamic>)
        .map((json) => DoctorAvailabilityModel.fromMap(json))
        .toList();
  }
}
