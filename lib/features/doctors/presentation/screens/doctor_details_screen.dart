import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/arabic_date.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_args_model.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_model.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/screens/doctor_availability_screen.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor.dart';
import 'package:shefaa_app/features/doctors/domain/entities/doctor_schedule.dart';
import 'package:shefaa_app/features/doctors/presentation/bloc/doctor_details_bloc.dart';
import 'package:shefaa_app/generated/l10n.dart';

/// The doctor's page: who they are, what a visit costs, and which days they
/// work -- before the patient has to pick a date to find any of that out.
class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key, required this.doctor});

  static const String routeName = '/doctor-details';

  final DoctorEntity doctor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DoctorDetailsBloc>()..add(GetDoctorScheduleEvent(doctor.id)),
      child: Scaffold(
        appBar: CustomAppBar(title: doctor.name),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Constants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(doctor: doctor),
                      const SizedBox(height: 16),
                      _Facts(doctor: doctor),
                      if ((doctor.bio ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _Section(
                          title: 'نبذة عن الطبيب',
                          child: Text(
                            doctor.bio!.trim(),
                            style: TextStyles.meduim14
                                .copyWith(color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const _WeeklySchedule(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Constants.padding),
                child: CustomButton(
                  title: S.of(context).book_now,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    DoctorAvailabilityScreen.routeName,
                    arguments: DoctorAvailabilityArgsModel(doctorId: doctor.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.doctor});
  final DoctorEntity doctor;

  @override
  Widget build(BuildContext context) {
    final hasImage = doctor.image?.isNotEmpty ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xffE8F3FF),
          backgroundImage: hasImage ? NetworkImage(doctor.image!) : null,
          child: hasImage
              ? null
              : const Icon(Icons.person, size: 36, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor.name, style: TextStyles.bold18),
              const SizedBox(height: 4),
              Text(
                doctor.title ?? doctor.specialaization,
                style: TextStyles.meduim14.copyWith(color: Colors.grey.shade600),
              ),
              if (doctor.rating != null && doctor.rating! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating!.toStringAsFixed(1),
                      style: TextStyles.meduim14,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.doctor});
  final DoctorEntity doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _Fact(
            icon: Icons.payments_outlined,
            label: S.of(context).consultation_fee,
            value: '${doctor.consultationFee ?? 0} ${S.of(context).currency}',
          ),
          if (doctor.waitingTime != null) ...[
            const SizedBox(height: 12),
            _Fact(
              icon: Icons.access_time,
              label: S.of(context).waiting_time,
              value: '${doctor.waitingTime} ${S.of(context).minutes}',
            ),
          ],
          if ((doctor.location ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            _Fact(
              icon: Icons.location_on_outlined,
              label: 'العيادة',
              value: doctor.location!,
            ),
          ],
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 10),
        Text(label, style: TextStyles.meduim14.copyWith(color: Colors.grey.shade700)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyles.bold14.copyWith(color: Colors.black),
          ),
        ),
      ],
    );
  }
}

/// The weekly pattern. Not the same as "you can book this day" -- a date can
/// still be closed by an exception -- so it says so rather than implying the
/// days listed are all open.
class _WeeklySchedule extends StatelessWidget {
  const _WeeklySchedule();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorDetailsBloc, DoctorDetailsState>(
      builder: (context, state) {
        if (state.scheduleState == RequestState.loading) {
          return const _Section(
            title: 'أيام العمل',
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (state.scheduleState == RequestState.error) {
          return _Section(
            title: 'أيام العمل',
            child: Text(
              state.errorMessage ?? 'تعذر تحميل أيام العمل',
              style: TextStyles.meduim14.copyWith(color: Colors.redAccent),
            ),
          );
        }

        final byDay = state.byWeekday;
        if (byDay.isEmpty) {
          return _Section(
            title: 'أيام العمل',
            child: Text(
              'لم يحدد الطبيب أيام عمله بعد',
              style: TextStyles.meduim14.copyWith(color: Colors.grey.shade600),
            ),
          );
        }

        return _Section(
          title: 'أيام العمل',
          subtitle: 'المواعيد المتاحة في يوم معين قد تختلف',
          child: Column(
            children: [
              for (final entry in byDay.entries) ...[
                _DayRow(weekday: entry.key, sessions: entry.value),
                if (entry.key != byDay.keys.last) const Divider(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.weekday, required this.sessions});

  final int weekday;
  final List<DoctorScheduleEntity> sessions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(arabicWeekdayName(weekday), style: TextStyles.bold14),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final session in sessions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${session.isMorning ? 'الفترة الصباحية' : 'الفترة المسائية'}'
                    ' · ${DoctorSessionModel.formatTime(session.startTime)}'
                    ' - ${DoctorSessionModel.formatTime(session.endTime)}',
                    style: TextStyles.meduim14
                        .copyWith(color: Colors.grey.shade700),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyles.bold16),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyles.meduim12.copyWith(color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
