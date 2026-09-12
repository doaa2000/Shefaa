import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/location/domain/entities/place.dart';
import 'package:shefaa_app/features/location/presentation/bloc/location_bloc.dart';
import 'package:shefaa_app/features/location/presentation/widgets/drop_down_field.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  static const String routeName = '/location';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LocationBloc>()..add(const LoadLocationEvent()),
      child: const _LocationView(),
    );
  }
}

class _LocationView extends StatelessWidget {
  const _LocationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحديد الموقع')),
      // BlocListener + BlocBuilder rather than BlocConsumer: this version of
      // BlocConsumer reaches its listener through buildWhen, so a Navigator
      // call from there happens during a build and does nothing.
      body: BlocListener<LocationBloc, LocationState>(
        listenWhen: (previous, current) => current.saved && !previous.saved,
        listener: (context, state) => Navigator.pop(context, true),
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state.governoratesState == RequestState.loading &&
                state.governorates.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.governoratesState == RequestState.error) {
              return _ErrorBody(
                message: state.errorMessage,
                onRetry: () =>
                    context.read<LocationBloc>().add(const LoadLocationEvent()),
              );
            }

            final bloc = context.read<LocationBloc>();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Constants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختيار المدينة يعرض الأطباء العاملين في عياداتها فقط.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  DropdownField<PlaceEntity>(
                    title: 'المحافظة',
                    hint: 'اختيار المحافظة',
                    items: state.governorates,
                    labelOf: (place) => place.name,
                    value: state.selectedGovernorate,
                    isOpen: state.isGovernorateOpen,
                    emptyText: 'لا توجد محافظات مسجلة.',
                    onToggle: () =>
                        bloc.add(const ToggleGovernorateDropdownEvent()),
                    onSelect: (place) => bloc.add(SelectGovernorateEvent(place)),
                  ),

                  const SizedBox(height: 20),

                  DropdownField<PlaceEntity>(
                    title: 'المدينة',
                    hint: state.selectedGovernorate == null
                        ? 'اختيار المحافظة أولًا'
                        : 'اختيار المدينة',
                    items: state.cities,
                    labelOf: (place) => place.name,
                    value: state.selectedCity,
                    isOpen: state.isCityOpen,
                    isLoading: state.citiesState == RequestState.loading,
                    emptyText: 'لا توجد مدن مسجلة في هذه المحافظة.',
                    // Disabled until there is a governorate: the list of cities
                    // is a list of the cities inside one, and there is no answer
                    // to give before then.
                    onToggle: state.selectedGovernorate == null
                        ? null
                        : () => bloc.add(const ToggleCityDropdownEvent()),
                    onSelect: (place) => bloc.add(SelectCityEvent(place)),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: state.canSave
                          ? () => bloc.add(const SaveLocationEvent())
                          : null,
                      child: const Text('حفظ'),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // A patient who narrowed to a city with two doctors in it has
                  // to be able to widen again.
                  Center(
                    child: TextButton(
                      onPressed: () => bloc.add(const ClearLocationEvent()),
                      child: const Text('عرض جميع المدن'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined,
                size: 44, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'تعذر تحميل المحافظات.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}
