import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';

import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_event.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_state.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/booking_card.dart';
import 'package:shefaa_app/features/bookings/presentation/widgets/booking_toggle.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookingBloc>()
        ..add(const GetMyBookingsEvent()),
      child: Padding(
        padding: EdgeInsets.all(Constants.padding),
        child: Column(
          children: [
            // BookingToggle(
            //   selectedIndex: selectedIndex,
            //   onToggle: (index) => setState(() => selectedIndex = index),
            // ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {

                  if (state.getBookingsState == RequestState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.getBookingsState == RequestState.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 40),
                          const SizedBox(height: 8),
                          Text(state.errorMessage ?? 'حدث خطأ'),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context
                                .read<BookingBloc>()
                                .add(const GetMyBookingsEvent()),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  // ✅ Data
                  return _buildBookings(state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookings(BookingState state) {
    final confirmed = state.bookings
        .where((b) => b.status == 'confirmed')
        .toList();

    final completed = state.bookings
        .where((b) => b.status == 'completed')
        .toList();

    final cancelled = state.bookings
        .where((b) => b.status == 'cancelled')
        .toList();

    final List<BookingEntity> list = switch (selectedIndex) {
      0 => confirmed,
      1 => completed,
      2 => cancelled,
      _ => [],
    };

    if (list.isEmpty) {
      return Center(
        child: Text(
          selectedIndex == 0
              ? 'لا توجد حجوزات قادمة'
              : selectedIndex == 1
                  ? 'لا توجد حجوزات مكتملة'
                  : 'لا توجد حجوزات ملغاة',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingBloc>().add(const GetMyBookingsEvent()); 
      },
      child: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = list[index];
          return BookingCard(
            doctorName: booking.doctor.name,
            specialty:   booking.doctor.specialaization,
            date:        booking.bookedDate.toString().split(' ')[0],
            time:        booking.startTime,
            status:      booking.status,
            amount:      booking.payment.amount,
            paymentMethod: booking.payment.paymentMethod,
          );
        },
      ),
    );
  }
}