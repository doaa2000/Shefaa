import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/arabic_date.dart';
import 'package:shefaa_app/core/widgets/card_container.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/generated/l10n.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.booking});

  final BookingEntity booking;

  static const Map<String, (String, Color)> _statusLabels = {
    'confirmed': ('مؤكد', Colors.green),
    'pending': ('قيد التأكيد', Colors.orange),
    'completed': ('تم', Colors.blue),
    'cancelled': ('ملغي', Colors.grey),
    'no_show': ('لم يحضر', Colors.brown),
  };

  String get _sessionLabel =>
      booking.session == 'morning' ? 'الفترة الصباحية' : 'الفترة المسائية';

  /// The window the doctor sees patients in. There is no per-patient time --
  /// the queue number is what says when it is your turn.
  String get _window {
    final start = DoctorSessionModel.formatTime(booking.startTime);
    final end = DoctorSessionModel.formatTime(booking.endTime);
    if (start.isEmpty && end.isEmpty) return _sessionLabel;
    if (end.isEmpty) return '$_sessionLabel · $start';
    return '$_sessionLabel · $start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) =
        _statusLabels[booking.status] ?? (booking.status, Colors.grey);

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.of(context).your_appointment,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AppointmentRow(
            icon: Icons.calendar_month,
            title: 'التاريخ',
            value: fullArabicDate(booking.bookedDate),
          ),
          const SizedBox(height: 12),
          _AppointmentRow(
            icon: Icons.access_time,
            title: 'الفترة',
            value: _window,
          ),
          // A queue position on a visit that has already been and gone means
          // nothing, so it is only shown while the booking is still ahead.
          if (booking.queueNumber != null && booking.isUpcoming) ...[
            const SizedBox(height: 12),
            _AppointmentRow(
              icon: Icons.confirmation_number_outlined,
              title: 'دورك',
              value: booking.queueNumber! > 1
                  ? 'رقم ${booking.queueNumber} · قدامك ${booking.queueNumber! - 1}'
                  : 'رقم ${booking.queueNumber} · مفيش حد قدامك',
            ),
          ],
          const SizedBox(height: 12),
          _AppointmentRow(
            icon: Icons.tag,
            title: 'رقم الحجز',
            value: '#${booking.id}',
          ),
          if (booking.doctor.location != null &&
              booking.doctor.location!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _AppointmentRow(
              icon: Icons.location_on_outlined,
              title: 'العيادة',
              value: booking.doctor.location!,
            ),
          ],
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AppointmentRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
