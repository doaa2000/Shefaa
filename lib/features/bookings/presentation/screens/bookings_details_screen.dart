import 'package:flutter/material.dart';
import 'package:shefaa_app/core/services/booking_policy.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/appointment_card.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/payment_summary_card.dart';
import 'package:shefaa_app/generated/l10n.dart';

/// What the details screen asks the list to do on its way out.
///
/// It has no bloc of its own and the list has, so it decides and the list
/// acts. Two values rather than a bool, because there are now two things it
/// can decide.
enum BookingAction { cancel, reportAbsence }

/// A rating on its way back to the list, which is where the bloc is.
///
/// Not a third enum value: this one carries what the patient said, and an
/// enum cannot. The list checks the type rather than the value.
class BookingRated {
  final int stars;
  final String? comment;

  const BookingRated({required this.stars, this.comment});
}

class BookingsDetailsScreen extends StatelessWidget {
  const BookingsDetailsScreen({super.key, required this.booking});

  static const routeName = '/bookings_details_screen';

  final BookingEntity booking;

  static const List<String> _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// "٤:٠٠ م" for today, and the date as well for any other day: a bare time
  /// on a booking three days out says nothing about which day it runs out.
  static String _formatDeadline(DateTime deadline) {
    final hour12 = deadline.hour % 12 == 0 ? 12 : deadline.hour % 12;
    final minute = deadline.minute.toString().padLeft(2, '0');
    final period = deadline.hour < 12 ? 'ص' : 'م';
    final time = '$hour12:$minute $period';

    final now = DateTime.now();
    final isToday = deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day;
    if (isToday) return time;

    return '$time يوم ${deadline.day} ${_monthNames[deadline.month - 1]}';
  }

  /// Popping with true means "cancel this booking". The bookings list owns the
  /// BookingBloc, so it is the one that dispatches the cancel and reports the
  /// result -- this screen is gone by then.
  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).cancel_booking),
        content: Text(
          'إلغاء حجزك مع ${booking.doctor.name}؟\n'
          'سيصبح مكانك متاحاً لغيرك، ولا يمكن التراجع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: Text(S.of(context).cancel_booking),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, BookingAction.cancel);
    }
  }

  /// Deliberately worded as telling the clinic rather than cancelling, and
  /// says the booking stands. A patient who presses this expecting a refund
  /// or a freed place has been misled by the button, not by the clinic.
  Future<void> _confirmAbsence(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إبلاغ العيادة'),
        content: Text(
          'سنُبلِغ الدكتور ${booking.doctor.name} بتعذّر الحضور.\n'
          'مهلة الإلغاء انتهت، فالحجز يبقى قائماً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('إبلاغ'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, BookingAction.reportAbsence);
    }
  }

  /// Collects the stars, then hands them to the list to send.
  Future<void> _rate(BuildContext context) async {
    final rated = await showModalBottomSheet<BookingRated>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _RateSheet(booking: booking),
    );

    if (rated != null && context.mounted) {
      Navigator.pop(context, rated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = booking.doctor;
    final hasImage = doctor.image?.isNotEmpty ?? false;

    return Scaffold(
      appBar: CustomAppBar(title: S.of(context).booking_details),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xffE8F3FF),
                            backgroundImage:
                                hasImage ? NetworkImage(doctor.image!) : null,
                            child: hasImage
                                ? null
                                : const Icon(
                                    Icons.person,
                                    size: 32,
                                    color: AppColors.primaryColor,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(doctor.name, style: TextStyles.bold18),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.specialaization,
                                  style: TextStyles.regular14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppointmentCard(booking: booking),
                    const SizedBox(height: 12),
                    PaymentSummaryCard(booking: booking),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // A booking that has already happened or was cancelled has nothing
            // left to cancel, so the button is simply not there.
            if (booking.canCancel) ...[
              // Only when cancelling closes before the appointment does. With
              // no notice period the deadline is the appointment itself, and
              // "cancellable until five" above an appointment at five is a
              // line that reads like a rule and states nothing.
              if (BookingPolicy.instance.cancellationNotice > Duration.zero) ...[
                const SizedBox(height: 8),
                Text(
                  'يمكن الإلغاء حتى ${_formatDeadline(booking.cancelDeadline)}',
                  style:
                      TextStyles.meduim12.copyWith(color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 8),
              CustomButton(
                title: S.of(context).cancel_booking,
                backgroundColor: Colors.red.shade700,
                onPressed: () => _confirmCancel(context),
              ),
            ] else if (booking.canReportAbsence) ...[
              // This used to say "please contact the clinic" and stop there,
              // which is a dead end: there is no number on this screen and
              // there is not going to be one. The button does the one useful
              // thing that telephone call would have done.
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'انتهت مهلة إلغاء هذا الحجز. إذا تعذّر الحضور، '
                  'يمكن إبلاغ العيادة ليتاح المكان لغيرك.',
                  style: TextStyles.meduim12
                      .copyWith(color: Colors.grey.shade700, height: 1.7),
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                title: 'لن أتمكّن من الحضور',
                backgroundColor: Colors.grey.shade700,
                onPressed: () => _confirmAbsence(context),
              ),
            ] else if (booking.canReview) ...[
              // A visit that happened. Nothing to cancel and nothing to warn
              // the clinic about -- the one thing left is what the patient
              // thought of it, which is the only place the doctor's rating on
              // the search screen has ever come from.
              const SizedBox(height: 12),
              if (booking.reviewed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'تقييمك لهذه الزيارة',
                            style: TextStyles.meduim12
                                .copyWith(color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 8),
                          for (var star = 1; star <= 5; star++)
                            Icon(
                              star <= booking.reviewStars!
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            ),
                        ],
                      ),
                      if (booking.reviewComment != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          booking.reviewComment!,
                          style: TextStyles.meduim12.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  title: 'تعديل التقييم',
                  backgroundColor: Colors.grey.shade700,
                  onPressed: () => _rate(context),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'رأيك يساعد غيرك على اختيار الطبيب المناسب.',
                    style: TextStyles.meduim12
                        .copyWith(color: Colors.grey.shade700, height: 1.7),
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  title: 'قيّم زيارتك',
                  onPressed: () => _rate(context),
                ),
              ],
            ] else if (booking.isUpcoming && booking.absenceReported) ...[
              // Said once and then stated, so the patient is not left
              // wondering whether the first press did anything.
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'تم إبلاغ العيادة بتعذّر الحضور. الحجز ما زال قائماً.',
                  style: TextStyles.meduim12
                      .copyWith(color: Colors.grey.shade700, height: 1.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// The star picker.
///
/// Its own widget because it is the one thing on this screen that holds state
/// while the patient makes up their mind, and the screen around it is
/// stateless on purpose.
class _RateSheet extends StatefulWidget {
  const _RateSheet({required this.booking});

  final BookingEntity booking;

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  late int _stars = widget.booking.reviewStars ?? 0;
  late final TextEditingController _comment =
      TextEditingController(text: widget.booking.reviewComment ?? '');

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    if (_stars == 0) return;
    final note = _comment.text.trim();
    Navigator.pop(
      context,
      BookingRated(stars: _stars, comment: note.isEmpty ? null : note),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lifted above the keyboard, so the note field is not written blind.
      padding: EdgeInsets.only(
        left: Constants.padding,
        right: Constants.padding,
        top: Constants.padding,
        bottom: MediaQuery.of(context).viewInsets.bottom + Constants.padding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('كيف كانت زيارتك؟', style: TextStyles.bold18),
          const SizedBox(height: 4),
          Text(
            widget.booking.doctor.name,
            style: TextStyles.meduim14.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  // A big target: this is the only control that matters here,
                  // and a five-way choice of small icons is a mis-tap waiting.
                  iconSize: 36,
                  onPressed: () => setState(() => _stars = star),
                  icon: Icon(
                    star <= _stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _comment,
            maxLines: 3,
            maxLength: 1000,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'ملاحظة للمرضى الآخرين (اختياري)',
              hintStyle:
                  TextStyles.meduim12.copyWith(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CustomButton(
            title: 'إرسال التقييم',
            // Off until a star is chosen. A review with no stars is not a
            // review, and the database refuses one anyway.
            onPressed: _stars == 0 ? null : _submit,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
