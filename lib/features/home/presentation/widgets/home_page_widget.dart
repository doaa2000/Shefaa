import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_search_bar.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctor_search_screen.dart';
import 'package:shefaa_app/features/home/presentation/widgets/specialties_grid.dart';
import 'package:shefaa_app/features/home/presentation/widgets/upcoming_appointment_section.dart';
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
            // The bar on the home screen is a doorway, not a field: tapping
            // it opens the search screen, which owns the keyboard, the results
            // and the debounce. It sat here doing nothing at all before.
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                DoctorSearchScreen.routeName,
              ),
              child: const AbsorbPointer(
                child: CustomSearchBar(
                  hintText: 'ابحث باسم الطبيب أو التخصص',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(S.of(context).specialties, style: TextStyles.bold18),
            SpecialtiesGrid(),
            const UpcomingAppointmentSection(),
          ],
        ),
      ),
    );
  }
}
