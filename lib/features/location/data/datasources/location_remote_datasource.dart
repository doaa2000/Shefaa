import 'package:shefaa_app/features/location/data/models/place_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LocationRemoteDatasource {
  Future<List<PlaceModel>> getGovernorates();

  Future<List<PlaceModel>> getCities(int governorateId);
}

class LocationRemoteDatasourceImpl implements LocationRemoteDatasource {
  final SupabaseClient supabase;

  LocationRemoteDatasourceImpl(this.supabase);

  @override
  Future<List<PlaceModel>> getGovernorates() async {
    final response =
        await supabase.from('Governorates').select('id, name').order('name');

    return (response as List)
        .map((e) => PlaceModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PlaceModel>> getCities(int governorateId) async {
    final response = await supabase
        .from('Cities')
        .select('id, name')
        .eq('governorate_id', governorateId)
        .order('name');

    return (response as List)
        .map((e) => PlaceModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
