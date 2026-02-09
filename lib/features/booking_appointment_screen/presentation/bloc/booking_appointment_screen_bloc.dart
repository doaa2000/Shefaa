import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'booking_appointment_screen_event.dart';
part 'booking_appointment_screen_state.dart';

class BookingAppointmentScreenBloc extends Bloc<BookingAppointmentScreenEvent, BookingAppointmentScreenState> {
  BookingAppointmentScreenBloc() : super(BookingAppointmentScreenInitial()) {
    on<BookingAppointmentScreenEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
