import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_search_bar.dart';
import 'package:shefaa_app/features/doctor_availability/data/models/doctor_availability_args_model.dart';
import 'package:shefaa_app/features/doctor_availability/presentation/screens/doctor_availability_screen.dart';
import 'package:shefaa_app/features/doctors/presentation/bloc/doctor_search_bloc.dart';
import 'package:shefaa_app/features/doctors/presentation/screens/doctor_details_screen.dart';
import 'package:shefaa_app/features/doctors/presentation/widgets/doctors_card.dart';

class DoctorSearchScreen extends StatelessWidget {
  const DoctorSearchScreen({super.key});

  static const String routeName = '/doctor-search';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DoctorSearchBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// One query per pause, not one per keystroke. Without this, typing a
  /// doctor's name sends a request per letter and the answers race each other
  /// back.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<DoctorSearchBloc>().add(SearchDoctorsEvent(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'البحث عن طبيب'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: Column(
            children: [
              CustomSearchBar(
                controller: _controller,
                onChanged: _onChanged,
                hintText: 'ابحث باسم الطبيب أو التخصص',
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<DoctorSearchBloc, DoctorSearchState>(
                  builder: (context, state) => _results(context, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _results(BuildContext context, DoctorSearchState state) {
    if (!state.hasSearched) {
      return const _Hint(
        icon: Icons.search,
        text: 'اكتب اسم الطبيب أو التخصص للبحث',
      );
    }

    if (state.searchState == RequestState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.searchState == RequestState.error) {
      return _Hint(
        icon: Icons.error_outline,
        text: state.errorMessage ?? 'تعذر البحث. يرجى المحاولة مرة أخرى',
        color: Colors.redAccent,
      );
    }

    if (state.doctors.isEmpty) {
      return _Hint(
        icon: Icons.person_search_outlined,
        text: 'لا يوجد طبيب باسم "${state.query}"',
      );
    }

    return ListView.separated(
      itemCount: state.doctors.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doctor = state.doctors[index];
        return DoctorCard(
          name: doctor.name,
          specialty: doctor.title ?? doctor.specialaization,
          imageUrl: doctor.image ?? '',
          consultationFee: doctor.consultationFee ?? 0,
          location: doctor.location ?? 'غير محدد',
          waitingTime:
              doctor.waitingTime != null ? '${doctor.waitingTime}' : '—',
          rating: doctor.rating ?? 0,
          onDetailsTap: () => Navigator.pushNamed(
            context,
            DoctorDetailsScreen.routeName,
            arguments: doctor,
          ),
          onBookTap: () => Navigator.pushNamed(
            context,
            DoctorAvailabilityScreen.routeName,
            arguments: DoctorAvailabilityArgsModel(doctorId: doctor.id),
          ),
        );
      },
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 44, color: color ?? Colors.grey.shade400),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyles.meduim14
                  .copyWith(color: color ?? Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
