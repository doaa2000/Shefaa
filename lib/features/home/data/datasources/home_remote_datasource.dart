import 'package:shefaa_app/core/model/specialty_model.dart';
import 'package:shefaa_app/features/home/data/models/specialty_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDatasource {
  Future<List<SpecialtyModel>> getSpecialties();
}
class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final SupabaseClient supabase;

  HomeRemoteDatasourceImpl(this.supabase);
@override
Future<List<SpecialtyModel>> getSpecialties() async {
  final response = await supabase
      .from('specialties')
      .select();

  final data = response as List<dynamic>;

  return data
      .map((json) => SpecialtyModel.fromMap(json))
      .toList();
}
}