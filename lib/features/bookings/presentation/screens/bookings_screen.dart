import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_event.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_state.dart';
import 'package:shefaa_app/features/bookings/presentation/screens/bookings_details_screen.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/booking_card.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<BookingBloc>()..add(const GetMyBookingsEvent()),
      child: const _BookingsView(),
    );
  }
}

class _BookingsView extends StatefulWidget {
  const _BookingsView();

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView> {
  int _tab = 0;

  static const _tabs = ['القادمة', 'السابقة', 'الملغاة'];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listenWhen: (p, c) => p.cancelBookingState != c.cancelBookingState,
      listener: (context, state) {
        if (state.cancelBookingState == RequestState.loaded) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('تم إلغاء الحجز')));
        }
        if (state.cancelBookingState == RequestState.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'تعذر إلغاء الحجز'),
              backgroundColor: Colors.red.shade700,
            ));
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: Column(
            children: [
              _Tabs(
                tabs: _tabs,
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 16),
              Expanded(child: _body(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, BookingState state) {
    if (state.getBookingsState == RequestState.loading &&
        state.bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.getBookingsState == RequestState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(state.errorMessage ?? 'حدث خطأ', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  context.read<BookingBloc>().add(const GetMyBookingsEvent()),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final list = switch (_tab) {
      0 => state.upcoming,
      1 => state.past,
      _ => state.cancelled,
    };

    if (list.isEmpty) {
      return _Empty(tab: _tab);
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<BookingBloc>().add(const GetMyBookingsEvent()),
      child: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = list[index];
          return BookingCard(
            booking: booking,
            // Only an upcoming booking can be cancelled.
            onCancel: _tab == 0 ? () => _confirmCancel(context, booking) : null,
            onTap: () => _openDetails(context, booking),
          );
        },
      ),
    );
  }

  /// The details screen has no bloc of its own; it pops with true when the
  /// patient confirms a cancel there, and the cancel runs here where the
  /// BookingBloc and the result snackbar already live.
  Future<void> _openDetails(BuildContext context, BookingEntity booking) async {
    final bloc = context.read<BookingBloc>();
    final cancelRequested = await Navigator.pushNamed(
      context,
      BookingsDetailsScreen.routeName,
      arguments: booking,
    );

    if (cancelRequested == true) {
      bloc.add(CancelBookingEvent(booking.id));
    }
  }

  Future<void> _confirmCancel(
    BuildContext context,
    BookingEntity booking,
  ) async {
    final bloc = context.read<BookingBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الحجز'),
        content: Text(
          'هتلغي حجزك مع ${booking.doctor.name}؟\n'
          'مكانك هيروح لغيرك ومش هينفع ترجعيه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('إلغاء الحجز'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(CancelBookingEvent(booking.id));
    }
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyles.meduim14.copyWith(
                      color: selected == i
                          ? AppColors.primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.tab});
  final int tab;

  @override
  Widget build(BuildContext context) {
    final (icon, text) = switch (tab) {
      0 => (Icons.event_available_outlined, 'مفيش حجوزات قادمة'),
      1 => (Icons.history, 'مفيش حجوزات سابقة'),
      _ => (Icons.event_busy_outlined, 'مفيش حجوزات ملغاة'),
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(text, style: TextStyles.meduim14.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}
