import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_consent.dart';
import 'package:shefaa_app/core/utils/app_legal.dart';
import 'package:shefaa_app/core/utils/app_router.dart';
import 'package:shefaa_app/features/consent/domain/usecases/consent_usecases.dart';

/// Where a signed-in patient goes next: home, or a screen asking for an
/// agreement this account still owes.
///
/// One place rather than three. The splash screen, the login screen and the
/// consent screens themselves all have to answer the same question, and a gate
/// that is written out separately in each of them is a gate that closes in
/// only some of them.
///
/// The order is fixed: the terms and the privacy notice come first, because
/// they describe the service itself, and the health-data consent second,
/// because it is about what the service then stores.
class ConsentGate {
  const ConsentGate._();

  static Future<String> nextRoute() async {
    // All three at once. They are three separate rows and so three separate
    // questions, but asking them one after the other would put three round
    // trips in front of the splash screen where one is enough.
    final answers = await Future.wait([
      _accepted('terms', AppLegal.termsVersion),
      _accepted('privacy', AppLegal.privacyVersion),
      _accepted('health_data', AppConsent.healthDataVersion),
    ]);

    if (!answers[0] || !answers[1]) return AppRoutes.legalAcceptance;
    if (!answers[2]) return AppRoutes.healthConsent;

    return AppRoutes.home;
  }

  /// A failure counts as accepted. The alternative is a patient with no
  /// signal being held at a gate by a round trip that never came back; they
  /// are asked again on the next launch that does reach the server.
  static Future<bool> _accepted(String kind, String version) async {
    final result = await getIt<HasAcceptedConsentUseCase>()(
      ConsentParams(kind: kind, version: version),
    );
    return result.fold((_) => true, (accepted) => accepted);
  }
}
