import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/doctors/data/models/doctors_args_model.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctors_screen.dart';
import 'package:shefaa_app/features/home/presentation/bloc/home_bloc.dart';

class SpecialtiesGrid extends StatelessWidget {
  const SpecialtiesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // 🔄 Loading
        if (state.specialtiesState == RequestState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (state.specialtiesState == RequestState.error) {
          return const Center(child: Text('Something went wrong'));
        }

        // 📭 Empty
        if (state.specialties.isEmpty) {
          return const Center(child: Text('No specialties found'));
        }

        // ✅ Loaded
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.specialties.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final specialty = state.specialties[index];

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  DoctorsScreen.routeName,
                  arguments: DoctorsArgsModel(
                    specialtyId: specialty.id,
                    specialtyName: specialty.name,
                  ),
                );
              },
              child: Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services, 
                      size: 32,
                      color: AppColors.primaryColor,
                    ),
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
      },
    );
  }
}