import 'package:flutter/material.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/cache_helper.dart';
import 'package:shefaa_app/core/widgets/error_sheet.dart';
import 'package:shefaa_app/features/bookings/domain/entites/pending_review.dart';
import 'package:shefaa_app/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:shefaa_app/features/bookings/presentation/screens/bookings_details_screen.dart';
import 'package:shefaa_app/generated/l10n.dart';

/// Asks the patient to rate a visit, once, the next time they open the app.
///
/// Not a notification. What this app interrupts people for is appointments --
/// booked, cancelled, tomorrow, in an hour -- and a message that turns out to
/// be a request for a favour teaches them that the next one might be nothing,
/// which is how the reminders stop being read. So the ask waits until they are
/// already here.
///
/// Draws nothing. It exists to run once, decide there is something to ask
/// about, and open the sheet over whatever is on screen.
class ReviewPrompt extends StatefulWidget {
  const ReviewPrompt({super.key});

  /// Remembers the one booking whose sheet was closed without an answer, so it
  /// is not put in front of them again. Per device, which is the right scope:
  /// it is about this person's patience, not about the review.
  static const String _dismissedKey = 'review_prompt_dismissed_booking';

  @override
  State<ReviewPrompt> createState() => _ReviewPromptState();
}

class _ReviewPromptState extends State<ReviewPrompt> {
  final _cache = CacheHelper();
  bool _asked = false;

  @override
  void initState() {
    super.initState();
    // After the first frame: the sheet needs a Navigator, and there is not one
    // yet while this is being built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAsk());
  }

  Future<void> _maybeAsk() async {
    // Once per launch, whatever happens below. A patient who switches tabs
    // should not be asked again on the way back.
    if (_asked) return;
    _asked = true;

    final result = await getIt<PendingReviewUsecase>()(const NoParameters());

    // A failure here is a question not asked, which is not worth a message.
    // The reviews are a nicety; the app is for booking appointments.
    final pending = result.fold((_) => null, (value) => value);
    if (pending == null || !mounted) return;

    final dismissed = _cache.getData(key: ReviewPrompt._dismissedKey);
    if (dismissed is int && dismissed == pending.bookingId) return;

    await _ask(pending);
  }

  Future<void> _ask(PendingReviewEntity pending) async {
    final rated = await showModalBottomSheet<BookingRated>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => RateSheet(doctorName: pending.doctorName),
    );

    if (rated == null) {
      // Closed without answering. Remembered so the same visit is not put in
      // front of them every time they open the app -- being asked once is a
      // request, being asked every morning is a reason to uninstall.
      await _cache.saveData(
        key: ReviewPrompt._dismissedKey,
        value: pending.bookingId,
      );
      return;
    }

    final result = await getIt<RateBookingUsecase>()(RateBookingParams(
      bookingId: pending.bookingId,
      stars: rated.stars,
      comment: rated.comment,
    ));

    if (!mounted) return;

    await result.fold(
      (failure) => showErrorSheet(context, failure.message),
      (_) async => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(S.of(context).review_thanks))),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
