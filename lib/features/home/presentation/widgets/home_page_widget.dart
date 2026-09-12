import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_search_bar.dart';
import 'package:shefaa_app/features/home/presentation/widgets/specialties_grid.dart';
import 'package:shefaa_app/features/home/presentation/widgets/upcoming_appointment_card.dart';
import 'package:shefaa_app/generated/l10n.dart';

class HomePageWidget extends StatelessWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchBar(),
            const SizedBox(height: 20),
            Text(S.of(context).specialties, style: TextStyles.bold18),
            SpecialtiesGrid(),
            const SizedBox(height: 20),
            Text(S.of(context).your_next_appointment, style: TextStyles.bold18),
            UpcomingAppointmentCard(
              doctorName: "د. دعاء عابدين",
              specialty: "أطفال",
              date: "12 فبراير 2026",
              time: "10:00 صباحًا",
            ),
          ],
        ),
      ),
    );
  }
}
