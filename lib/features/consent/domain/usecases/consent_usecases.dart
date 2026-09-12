import 'package:dartz/dartz.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/errors/failure.dart';
import 'package:shefaa_app/features/consent/domain/repositories/consent_repository.dart';

class ConsentParams {
  final String kind;
  final String version;

  const ConsentParams({required this.kind, required this.version});
}

class HasAcceptedConsentUseCase extends BaseUsecase<bool, ConsentParams> {
  final ConsentRepository repository;

  HasAcceptedConsentUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(ConsentParams params) {
    return repository.hasAccepted(kind: params.kind, version: params.version);
  }
}

class AcceptConsentUseCase extends BaseUsecase<Unit, ConsentParams> {
  final ConsentRepository repository;

  AcceptConsentUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ConsentParams params) {
    return repository.accept(kind: params.kind, version: params.version);
  }
}
