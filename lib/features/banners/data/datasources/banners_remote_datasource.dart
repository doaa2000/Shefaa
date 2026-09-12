import 'package:shefaa_app/features/banners/data/models/banner_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BannersRemoteDatasource {
  Future<List<BannerModel>> getBanners();
}

class BannersRemoteDatasourceImpl implements BannersRemoteDatasource {
  final SupabaseClient supabase;

  BannersRemoteDatasourceImpl(this.supabase);

  @override
  Future<List<BannerModel>> getBanners() async {
    // is_active is filtered by row level security as well; naming it here keeps
    // the query honest about what it wants rather than relying on the policy.
    final response = await supabase
        .from('banners')
        .select('id, image_url, title, subtitle')
        .eq('is_active', true)
        .order('sort_order')
        .order('id')
        .limit(10);

    return (response as List)
        .map((e) => BannerModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
