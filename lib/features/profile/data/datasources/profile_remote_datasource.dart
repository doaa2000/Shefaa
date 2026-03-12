import 'package:shefaa_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String userId);

  Future<void> updateProfile(UserModel user);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabase;

  ProfileRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> getProfile(String userId) async {
    final profile =
        await supabase.from('profiles').select().eq('id', userId).single();

    if (profile == null) {
      throw Exception('Profile not found');
    }

    return UserModel.fromMap(profile);
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    await supabase
        .from('profiles')
        .update({
          'name': user.name,
          'phone': user.phone,
          'gender': user.gender,
          'birth_date': user.birthDate,
        })
        .eq('id', user.id);
  }
}
