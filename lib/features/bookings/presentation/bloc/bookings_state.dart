
import 'package:equatable/equatable.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/features/bookings/domain/entites/booking.dart';

class BookingState extends Equatable {
  final RequestState createBookingState;
  final RequestState getBookingsState;
  final List<BookingEntity> bookings;
  final String? errorMessage;

  const BookingState({
    this.createBookingState = RequestState.initial,
    this.getBookingsState   = RequestState.initial,
    this.bookings           = const [],
    this.errorMessage,
  });

  BookingState copyWith({
    RequestState? createBookingState,
    RequestState? getBookingsState,
    List<BookingEntity>? bookings,
    String? errorMessage,
  }) {
    return BookingState(
      createBookingState: createBookingState ?? this.createBookingState,
      getBookingsState:   getBookingsState   ?? this.getBookingsState,
      bookings:           bookings           ?? this.bookings,
      errorMessage:       errorMessage       ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    createBookingState,
    getBookingsState,
    bookings,
    errorMessage,
  ];
}