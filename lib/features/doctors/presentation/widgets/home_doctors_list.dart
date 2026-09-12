import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/doctors/presentation/bloc/doctors_bloc.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_args_model.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/screens/doctor_availability_screen.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctor_details_screen.dart';
import 'package:shefaa_app/features/doctors/presentation/widgets/doctors_card.dart';

class HomeDoctorsList extends StatelessWidget {
  const HomeDoctorsList({super.key, this.specialtyName});

  /// Used only to word the empty state; the list itself is already filtered.
  final String? specialtyName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsBloc, DoctorsState>(
      builder: (context, state) {
        if (state.getDoctorsState == RequestState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.getDoctorsState == RequestState.error) {
          return _Message(
            icon: Icons.error_outline,
            color: Colors.red,
            text: state.errorMessage?.isNotEmpty == true
                ? state.errorMessage!
                : 'تعذر تحميل الأطباء',
            actionLabel: 'إعادة المحاولة',
            onAction: () {
              final specialtyId = state.specialtyId;
              if (specialtyId != null) {
                context
                    .read<DoctorsBloc>()
                    .add(GetDoctorsEvent(specialtyId: specialtyId));
              }
            },
          );
        }

        if (state.doctors.isEmpty) {
          return _Message(
            icon: Icons.person_search_outlined,
            color: Colors.grey,
            text: specialtyName == null
                ? 'لا يوجد أطباء متاحون حالياً'
                : 'لا يوجد أطباء في $specialtyName حالياً',
          );
        }

        return ListView.builder(
          itemCount: state.doctors.length,
          itemBuilder: (context, index) {
            final doctor = state.doctors[index];

            void openSlots() {
              Navigator.pushNamed(
                context,
                DoctorAvailabilityScreen.routeName,
                arguments: DoctorAvailabilityArgsModel(doctorId: doctor.id),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DoctorCard(
                name: doctor.name,
                specialty: doctor.title ?? doctor.specialaization,
                imageUrl: doctor.image ??
                    'https://i.pravatar.cc/150?img=${index + 3}',
                consultationFee: doctor.consultationFee ?? 0,
                location: doctor.location ?? 'غير محدد',
                waitingTime: doctor.waitingTime != null
                    ? '${doctor.waitingTime} دقيقة'
                    : '—',
                // The card opens the doctor's page; the button skips straight
                // to booking, which is what it says it does.
                onTap: () => Navigator.pushNamed(
                  context,
                  DoctorDetailsScreen.routeName,
                  arguments: doctor,
                ),
                onBookTap: openSlots,
              ),
            );
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.color,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(text, textAlign: TextAlign.center),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
