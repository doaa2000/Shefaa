import 'package:flutter/material.dart';
import 'package:shefaa_app/core/model/specialty_model.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctors_screen.dart';

class SpecialtiesGrid extends StatelessWidget {
  const SpecialtiesGrid({super.key});

  static final List<SpecialtyModel> specialties = [
    SpecialtyModel(name: 'Dentistry', icon: Icons.medical_services),
    SpecialtyModel(name: 'Obstetrics & Gynecology', icon: Icons.pregnant_woman),
    SpecialtyModel(name: 'Pediatrics', icon: Icons.child_care),
    SpecialtyModel(name: 'Ophthalmology', icon: Icons.remove_red_eye),
    SpecialtyModel(name: 'Internal Medicine', icon: Icons.local_hospital),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: specialties.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final specialty = specialties[index];

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, DoctorsScreen.routeName);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(specialty.icon, size: 32, color: AppColors.primaryColor),
                const SizedBox(height: 10),
                Text(
                  specialty.name,
                  textAlign: TextAlign.center,
                  style: TextStyles.meduim12,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
