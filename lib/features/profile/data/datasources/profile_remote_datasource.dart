import 'package:shefaa_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String userId);

  /// Writes the editable profile fields and returns the row as it now stands
  /// in the database, so the caller never has to guess what was stored.
  Future<UserModel> updateProfile(UserModel user);

  Future<void> updatePassword(String newPassword);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabase;

  ProfileRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> getProfile(String userId) async {
    final profile =
        await supabase.from('profiles').select().eq('id', userId).single();

    return _withAuthEmail(profile);
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final updated = await supabase
        .from('profiles')
        .update({
          'name': user.name,
          'phone': user.phone,
          'gender': user.gender,
          'birth_date': user.birthDate,
        })
        .eq('id', user.id)
        .select()
        .single();

    return _withAuthEmail(updated);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// `profiles` has no email column -- the address lives in `auth.users`.
  /// Without this every UserEntity built from a profile row would carry an
  /// empty email, which is what the profile header used to show.
  UserModel _withAuthEmail(Map<String, dynamic> row) {
    return UserModel.fromMap({
      ...row,
      'email': supabase.auth.currentUser?.email ?? '',
    });
  }
}
