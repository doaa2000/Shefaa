import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/services/selected_city_service.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/features/location/presentation/bloc/location_bloc.dart';
import 'package:shefaa_app/features/location/presentation/widgets/location_picker_body.dart';

/// The city filter, shown above a list of doctors.
///
/// It lives here rather than on the home screen because a filter belongs beside
/// the thing it filters: the home screen shows specialties, so narrowing by
/// city there changes nothing the patient can see.
class CityFilterBar extends StatelessWidget {
  const CityFilterBar({super.key, required this.onChanged});

  /// Called after the patient has picked or cleared a city, so the list behind
  /// can be read again.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final service = getIt<SelectedCityService>();

    return ValueListenableBuilder<SelectedCity?>(
      valueListenable: service.selection,
      builder: (context, selection, _) {
        final chosen = selection != null;

        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _open(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: chosen
                    ? AppColors.primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: chosen
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: chosen ? AppColors.primaryColor : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    chosen ? selection.cityName : 'كل المدن',
                    style: TextStyles.bold14.copyWith(
                      color: chosen ? AppColors.primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Clearing is one tap, right where the filter is. Sending the
                  // patient back into the picker to undo a filter is how a
                  // narrowed list becomes a permanent one.
                  if (chosen)
                    GestureDetector(
                      onTap: () async {
                        await service.clear();
                        onChanged();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    )
                  else
                    const Icon(Icons.keyboard_arrow_down,
                        size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _open(BuildContext context) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocProvider(
        create: (_) => getIt<LocationBloc>()..add(const LoadLocationEvent()),
        child: BlocListener<LocationBloc, LocationState>(
          listenWhen: (previous, current) => current.saved && !previous.saved,
          listener: (context, state) => Navigator.pop(context, true),
          child: SafeArea(
            child: Padding(
              // Leaves the sheet clear of the keyboard on a short screen, where
              // the open dropdown can push the buttons under it.
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  _SheetHandle(),
                  Flexible(child: LocationPickerBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (changed == true) onChanged();
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
