import 'package:dartz/dartz.dart';
import 'package:shefaa_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Raised when the account exists and the password is right, but the account
/// is not one of this app's: a doctor's or an administrator's.
///
/// A class of its own rather than a message, so the repository decides the
/// wording and the data layer stays out of the patient's language.
class NotAPatientAccountException implements Exception {
  const NotAPatientAccountException();
}

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    String? birthDate,
    String? gender,
    required String name,
    required String phone,
    required String healthConsentVersion,
  });
  Future<Unit> logout();

  /// Deletes the signed-in account, then signs out.
  Future<Unit> deleteAccount();
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

    await _requirePatientAccount();

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
  required String healthConsentVersion,
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
      // The consent goes the same way and for the same reason: it has to be
      // recorded in the same breath as the account, not after a sign-in that
      // may not happen for days.
      'health_consent_version': healthConsentVersion,
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

  /// All three apps sign in through the same auth, so a correct password is
  /// not on its own permission to be here. An account linked to a doctor or an
  /// administrator belongs to the dashboard or the admin panel; it is signed
  /// straight back out rather than left holding a session it should not have.
  Future<void> _requirePatientAccount() async {
    final allowed = await supabase.rpc('is_patient_account');
    if (allowed == true) return;

    await supabase.auth.signOut();
    throw const NotAPatientAccountException();
  }

  @override
  Future<Unit> logout() async {
    await supabase.auth.signOut();
    return unit;
  }

  @override
  Future<Unit> deleteAccount() async {
    // The function takes no arguments on purpose: it acts on auth.uid() and
    // there is no account it could be pointed at but the caller's own.
    await supabase.rpc('delete_my_account');

    // The session outlives the account it belonged to -- the token is still in
    // memory and still looks valid until it expires. Signing out here means the
    // app never sits on a session with nothing behind it.
    await supabase.auth.signOut();
    return unit;
  }
}
