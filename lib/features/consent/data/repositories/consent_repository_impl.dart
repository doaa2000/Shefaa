import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/consent/data/datasources/consent_remote_datasource.dart';
import 'package:shefaa_app/features/consent/domain/repositories/consent_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConsentRepositoryImpl implements ConsentRepository {
  final ConsentRemoteDatasource remoteDatasource;

  ConsentRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, bool>> hasAccepted({
    required String kind,
    required String version,
  }) async {
    try {
      return Right(
        await remoteDatasource.hasAccepted(kind: kind, version: version),
      );
    } catch (e) {
      return Left(ServerFailure(_message(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> accept({
    required String kind,
    required String version,
  }) async {
    try {
      await remoteDatasource.accept(kind: kind, version: version);
      return const Right(unit);
    } catch (e) {
      // Accepting the same version twice is the same fact, not an error the
      // patient should be shown: the unique index is what makes it so.
      if (e is PostgrestException && e.code == '23505') {
        return const Right(unit);
      }
      return Left(ServerFailure(_message(e)));
    }
  }

  static String _message(Object error) {
    if (error is PostgrestException) return error.message;
    return error.toString();
  }
}
