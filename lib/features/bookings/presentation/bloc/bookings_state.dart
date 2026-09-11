import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';

class BookingState extends Equatable {
  final RequestState createBookingState;
  final RequestState getBookingsState;
  final RequestState cancelBookingState;
  final List<BookingEntity> bookings;
  final String? errorMessage;

  /// The place the booking just made actually got, as the database assigned
  /// it. Not the number predicted on the session card -- that was read before
  /// anyone else had committed, and two patients can be shown the same one.
  final int? bookedQueueNumber;

  const BookingState({
    this.createBookingState = RequestState.initial,
    this.getBookingsState = RequestState.initial,
    this.cancelBookingState = RequestState.initial,
    this.bookings = const [],
    this.errorMessage,
    this.bookedQueueNumber,
  });

  /// Still to come: a place the patient still holds, on today or later.
  List<BookingEntity> get upcoming {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return bookings
        .where((b) => b.isUpcoming && !b.bookedDate.isBefore(startOfToday))
        .toList()
      ..sort((a, b) => a.bookedDate.compareTo(b.bookedDate));
  }

  /// Been and gone: attended, or a date that has passed without cancelling.
  List<BookingEntity> get past {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return bookings
        .where((b) =>
            b.status == 'completed' ||
            b.status == 'no_show' ||
            (b.isUpcoming && b.bookedDate.isBefore(startOfToday)))
        .toList()
      ..sort((a, b) => b.bookedDate.compareTo(a.bookedDate));
  }

  List<BookingEntity> get cancelled =>
      bookings.where((b) => b.status == 'cancelled').toList()
        ..sort((a, b) => b.bookedDate.compareTo(a.bookedDate));

  BookingState copyWith({
    RequestState? createBookingState,
    RequestState? getBookingsState,
    RequestState? cancelBookingState,
    List<BookingEntity>? bookings,
    String? errorMessage,
    int? bookedQueueNumber,
  }) {
    return BookingState(
      createBookingState: createBookingState ?? this.createBookingState,
      getBookingsState: getBookingsState ?? this.getBookingsState,
      cancelBookingState: cancelBookingState ?? this.cancelBookingState,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage ?? this.errorMessage,
      bookedQueueNumber: bookedQueueNumber ?? this.bookedQueueNumber,
    );
  }

  @override
  List<Object?> get props => [
        createBookingState,
        getBookingsState,
        cancelBookingState,
        bookings,
        errorMessage,
        bookedQueueNumber,
      ];
}
