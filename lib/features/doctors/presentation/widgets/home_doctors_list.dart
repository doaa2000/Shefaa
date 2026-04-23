import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/doctors/presentation/bloc/doctors_bloc.dart';
import 'package:shefaa_app/features/doctors/presentation/widgets/doctors_card.dart';

class HomeDoctorsList extends StatelessWidget {
  const HomeDoctorsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsBloc, DoctorsState>(
      builder: (context, state) {
        // 🔄 Loading
        if (state.getDoctorsState == RequestState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (state.getDoctorsState == RequestState.error) {
          return const Center(child: Text('Something went wrong'));
        }

        // 📭 Empty
        if (state.doctors.isEmpty) {
          return const Center(child: Text('No doctors found'));
        }

        // ✅ Loaded
        return ListView.builder(
          itemCount: state.doctors.length,
          itemBuilder: (context, index) {
            final doctor = state.doctors[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DoctorCard(
                name: doctor.name,
                specialty: doctor.title ?? '',
                imageUrl: doctor.image ??
                    'https://i.pravatar.cc/150?img=${index + 3}',
                   consultationFee: doctor.consultationFee ?? 0,
                    location: doctor.location ?? 'Unknown',
                    waitingTime: doctor.waitingTime != null
                    ? '${doctor.waitingTime} mins'
                    : 'N/A',
                onTap: () {
                  // TODO: navigate to doctor details
                },
              ),
            );
          },
        );
      },
    );
  }
}