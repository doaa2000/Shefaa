import 'package:dartz/dartz.dart';
import 'package:shefaa_app/features/auth/data/models/user_model.dart';
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
    // The handle_new_user trigger reads these, so the profile is complete
    // whether or not a session comes back. With email confirmation on there
    // is no session and the app cannot write to profiles at all -- it would
    // fail on row level security -- so this is the only route the details
    // have.
    data: {
      'name': name,
      'phone': phone,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
    },
  );

  final user = response.user;
  if (user == null) {
    throw const AuthException('لم يتم إنشاء الحساب. يرجى المحاولة مرة أخرى');
  }

  // Null with email confirmation on: the account exists, nobody is signed in
  // yet. `response.session!` here is what made registration crash outright the
  // moment confirmation was switched on.
  final session = response.session;

  if (session != null) {
    // Signed in already, so the details can be written directly -- which also
    // covers an account created before the trigger read metadata. upsert, not
    // insert: the trigger has already made this row.
    await supabase.from('profiles').upsert({
      'id': user.id,
      'name': name,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate,
    });
  }

  return UserModel(
    id: user.id,
    email: user.email ?? email,
    name: name,
    phone: phone,
    gender: gender,
    birthDate: birthDate,
    // Both null when the address still has to be confirmed. The bloc reads
    // that as "created, not signed in".
    accessToken: session?.accessToken,
    refreshToken: session?.refreshToken,
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
