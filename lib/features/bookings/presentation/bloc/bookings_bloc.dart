import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/domain/use_cases.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:shefaa_app/features/bookings/domain/usecases/get_booking_usecase.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_event.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUsecase createBookingUsecase;
  final GetMyBookingsUsecase getMyBookingsUsecase;
  final CancelBookingUsecase cancelBookingUsecase;
  final ReportAbsenceUsecase reportAbsenceUsecase;
  final RateBookingUsecase rateBookingUsecase;

  BookingBloc({
    required this.createBookingUsecase,
    required this.getMyBookingsUsecase,
    required this.cancelBookingUsecase,
    required this.reportAbsenceUsecase,
    required this.rateBookingUsecase,
  }) : super(const BookingState()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<GetMyBookingsEvent>(_onGetMyBookings);
    on<CancelBookingEvent>(_onCancelBooking);
    on<ReportAbsenceEvent>(_onReportAbsence);
    on<RateBookingEvent>(_onRateBooking);
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(createBookingState: RequestState.loading));

    final result = await createBookingUsecase(
      CreateBookingParams(
        doctorId: event.doctorId,
        paymentMethod: event.paymentMethod,
        bookedDate: event.bookedDate,
        session: event.session,
        startTime: event.startTime,
        endTime: event.endTime,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        createBookingState: RequestState.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(createBookingState: RequestState.loaded)),
    );
  }

  Future<void> _onGetMyBookings(
    GetMyBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(getBookingsState: RequestState.loading));

    final result = await getMyBookingsUsecase(NoParameters());

    result.fold(
      (failure) => emit(state.copyWith(
        getBookingsState: RequestState.error,
        errorMessage: failure.message,
      )),
      (bookings) => emit(state.copyWith(
        getBookingsState: RequestState.loaded,
        bookings: bookings,
      )),
    );
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(cancelBookingState: RequestState.loading));

    final result = await cancelBookingUsecase(event.bookingId);

    await result.fold(
      (failure) async => emit(state.copyWith(
        cancelBookingState: RequestState.error,
        errorMessage: failure.message,
      )),
      (_) async {
        emit(state.copyWith(cancelBookingState: RequestState.loaded));
        // Cancelling moves everyone behind this patient up a place, so the
        // whole list is re-read rather than the one row patched locally.
        add(const GetMyBookingsEvent());
      },
    );
  }

  Future<void> _onRateBooking(
    RateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(rateBookingState: RequestState.loading));

    final result = await rateBookingUsecase(RateBookingParams(
      bookingId: event.bookingId,
      stars: event.stars,
      comment: event.comment,
    ));

    await result.fold(
      (failure) async => emit(state.copyWith(
        rateBookingState: RequestState.error,
        errorMessage: failure.message,
      )),
      (_) async {
        emit(state.copyWith(rateBookingState: RequestState.loaded));
        // Re-read rather than patched: the review changes the doctor's average
        // too, and that number is on the same screens as this list.
        add(const GetMyBookingsEvent());
      },
    );
  }

  Future<void> _onReportAbsence(
    ReportAbsenceEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(reportAbsenceState: RequestState.loading));

    final result = await reportAbsenceUsecase(event.bookingId);

    await result.fold(
      (failure) async => emit(state.copyWith(
        reportAbsenceState: RequestState.error,
        errorMessage: failure.message,
      )),
      (_) async {
        emit(state.copyWith(reportAbsenceState: RequestState.loaded));
        // The place is still the patient's -- nothing moves -- but the row
        // now carries the report, and the list is what draws it.
        add(const GetMyBookingsEvent());
      },
    );
  }
}
