import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ConsentRemoteDatasource {
  /// Whether the signed-in patient has accepted this version of this consent.
  Future<bool> hasAccepted({required String kind, required String version});

  Future<void> accept({required String kind, required String version});
}

class ConsentRemoteDatasourceImpl implements ConsentRemoteDatasource {
  final SupabaseClient supabase;

  ConsentRemoteDatasourceImpl(this.supabase);

  @override
  Future<bool> hasAccepted({
    required String kind,
    required String version,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    // No session means no answer. Saying "yes" here would let the gate open on
    // an account nobody is signed in to; saying "no" is the safe direction.
    if (userId == null) return false;

    final rows = await supabase
        .from('consents')
        .select('id')
        .eq('user_id', userId)
        .eq('kind', kind)
        .eq('version', version)
        .limit(1);

    return (rows as List).isNotEmpty;
  }

  @override
  Future<void> accept({
    required String kind,
    required String version,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const PostgrestException(
        message: 'No authenticated user',
        code: 'not_signed_in',
      );
    }

    // The row is written with the patient's own id because the policy accepts
    // no other, and because a consent recorded on somebody's behalf is worth
    // less than none.
    //
    // upsert on the table's own unique key rather than insert: a tap that
    // timed out on the way back has already written the row, and the retry
    // must not fail on it. Accepting twice is the same fact, not an error.
    //
    // ignoreDuplicates, so the conflict does nothing instead of overwriting.
    // The table has no update policy on purpose -- a consent record that can
    // be rewritten afterwards is not a record -- and an upsert that tried to
    // update would be refused by it.
    await supabase.from('consents').upsert(
      {'user_id': userId, 'kind': kind, 'version': version},
      onConflict: 'user_id,kind,version',
      ignoreDuplicates: true,
    );
  }
}
