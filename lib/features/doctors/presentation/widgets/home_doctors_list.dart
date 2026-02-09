import 'package:flutter/material.dart';
import 'package:shefaa_app/features/doctors/presentation/widgets/doctors_card.dart';

class HomeDoctorsList extends StatelessWidget {
  const HomeDoctorsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,

      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: DoctorCard(
            name: 'Dr. Mohamed Hassan',
            specialty: 'Pediatrician',
            imageUrl: 'https://i.pravatar.cc/150?img=${index + 3}',
            onTap: () {
              // navigate to doctor details
            },
          ),
        );
      },
    );
  }
}
