import 'package:dartz/dartz.dart';
import 'package:shefaa_app/features/auth/data/models/user_model.dart';
import 'package:shefaa_app/features/auth/domain/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    String? birthDate,
    String? gender,
    required String name,
    required String phone,
  });
  Future<Unit> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user!;
    final session = response.session!;

    return UserModel(
      id: user.id,
      email: user.email!,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }

  @override
Future<UserModel> register({
  required String email,
  required String password,
  String? birthDate,
  String? gender,
  required String name,
  required String phone,
}) async {
  final response = await supabase.auth.signUp(
    email: email,
    password: password,
  );

  final user = response.user!;
  final session = response.session!; 

  await supabase.from('profiles').insert({
    'id': user.id,
    'name': name,
    'phone': phone,
    'gender': gender,
    'birth_date': birthDate,
  });

  return UserModel(
    id: user.id,
    email: user.email!,
    name: name,
    phone: phone,
    gender: gender,
    birthDate: birthDate,
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
  );
}

  Future<void> ensureProfileExists(String userId, String email) async {
  final profile = await supabase
      .from('profiles')
      .select()
      .eq('id', userId)
      .maybeSingle();

  if (profile == null) {
    await supabase.from('profiles').insert({
      'id': userId,
      'name': email.split('@').first,
    });
  }
}

  @override
  Future<Unit> logout() async {
    await supabase.auth.signOut();
    return unit;
  }
}
