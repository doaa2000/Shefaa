import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/errors/failure.dart';

abstract class ConsentRepository {
  Future<Either<Failure, bool>> hasAccepted({
    required String kind,
    required String version,
  });

  Future<Either<Failure, Unit>> accept({
    required String kind,
    required String version,
  });
}
