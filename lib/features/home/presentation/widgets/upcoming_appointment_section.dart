import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/arabic_date.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_event.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_state.dart';
import 'package:shefaa_app/features/bookings/presentation/screens/bookings_details_screen.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/generated/l10n.dart';

/// The patient's next booking, on the home screen.
///
/// This used to be four hardcoded strings -- a doctor called د. دعاء عابدين on
/// 12 فبراير 2026 -- shown to everyone who opened the app, including patients
/// who had never booked anything.
///
/// It fetches its own bookings rather than reading a bloc from above: the home
/// tab has no BookingBloc, and the bookings tab builds its own, so there is
/// nothing to share. The section hides itself entirely when there is nothing
/// coming up, rather than leaving an empty box on a new patient's home screen.
class UpcomingAppointmentSection extends StatelessWidget {
  const UpcomingAppointmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingBloc>()..add(const GetMyBookingsEvent()),
      child: BlocBuilder<BookingBloc, BookingState>(
        buildWhen: (previous, current) =>
            previous.getBookingsState != current.getBookingsState ||
            previous.bookings != current.bookings,
        builder: (context, state) {
          // Nothing to say yet, and nothing worth a spinner on a home screen
          // that has already drawn the rest of itself.
          if (state.getBookingsState != RequestState.loaded) {
            return const SizedBox.shrink();
          }

          final upcoming = state.upcoming;
          if (upcoming.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(S.of(context).your_next_appointment,
                  style: TextStyles.bold18),
              const SizedBox(height: 8),
              _Card(booking: upcoming.first),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.booking});

  final BookingEntity booking;

  String get _window {
    final start = DoctorSessionModel.formatTime(booking.startTime);
    final label = booking.session == 'morning'
        ? 'الفترة الصباحية'
        : 'الفترة المسائية';
    return start.isEmpty ? label : '$label · $start';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = booking.doctor.image?.isNotEmpty ?? false;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        BookingsDetailsScreen.routeName,
        arguments: booking,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              radius: 30,
              backgroundColor: AppColors.primaryColor,
              backgroundImage:
                  hasImage ? NetworkImage(booking.doctor.image!) : null,
              child: hasImage
                  ? null
                  : const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.doctor.specialaization,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        shortArabicDate(booking.bookedDate),
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _window,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // When to come, which is the whole promise. There is no
                  // number: the clinic sees people in the order they arrive.
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'يرجى الحضور في بداية الموعد',
                      style: TextStyles.bold14
                          .copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
