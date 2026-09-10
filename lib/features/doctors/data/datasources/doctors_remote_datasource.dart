import 'package:shefaa_app/features/doctors/data/models/doctor_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DoctorsRemoteDatasource {
  Future<List<DoctorModel>> getDoctors(int specialtyId);
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
}
