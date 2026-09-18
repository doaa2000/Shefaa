// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "review_thanks": MessageLookupByLibrary.simpleMessage(
      "Thank you for the rating",
    ),
    "booking_error_not_allowed": MessageLookupByLibrary.simpleMessage(
      "You do not have permission to do that",
    ),
    "booking_error_title": MessageLookupByLibrary.simpleMessage(
      "Something stopped this",
    ),
    "booking_error_close": MessageLookupByLibrary.simpleMessage(
      "OK",
    ),
    "booking_error_generic": MessageLookupByLibrary.simpleMessage(
      "The booking could not be completed. Please try again",
    ),
    "booking_error_invalid_stars": MessageLookupByLibrary.simpleMessage(
      "A rating is one to five stars",
    ),
    "booking_error_comment_too_long": MessageLookupByLibrary.simpleMessage(
      "That note is too long. Please shorten it",
    ),
    "booking_error_cancelled_not_rateable": MessageLookupByLibrary.simpleMessage(
      "A cancelled appointment cannot be rated",
    ),
    "booking_error_absent_not_rateable": MessageLookupByLibrary.simpleMessage(
      "An appointment you did not attend cannot be rated",
    ),
    "booking_error_appointment_not_yet": MessageLookupByLibrary.simpleMessage(
      "You can rate this once the appointment has started",
    ),
    "booking_error_session_full": MessageLookupByLibrary.simpleMessage(
      "This session is full. Please choose another",
    ),
    "booking_error_session_not_offered": MessageLookupByLibrary.simpleMessage(
      "The doctor does not hold this session on that day",
    ),
    "booking_error_already_booked": MessageLookupByLibrary.simpleMessage(
      "You already hold a place in this session",
    ),
    "booking_error_not_signed_in": MessageLookupByLibrary.simpleMessage(
      "Please sign in first",
    ),
    "booking_error_booking_immutable": MessageLookupByLibrary.simpleMessage(
      "A booking cannot be moved. Please cancel it and book again",
    ),
    "booking_error_cancel_only": MessageLookupByLibrary.simpleMessage(
      "Cancelling is the only change available",
    ),
    "booking_error_cancellation_closed": MessageLookupByLibrary.simpleMessage(
      "The time to cancel this booking has passed",
    ),
    "booking_error_time_has_passed": MessageLookupByLibrary.simpleMessage(
      "That appointment time has passed. Please choose another",
    ),
    "booking_error_date_in_past": MessageLookupByLibrary.simpleMessage(
      "That date has passed",
    ),
    "booking_error_beyond_horizon": MessageLookupByLibrary.simpleMessage(
      "That date is further ahead than bookings are open",
    ),
    "booking_error_booking_not_found": MessageLookupByLibrary.simpleMessage(
      "That booking no longer exists",
    ),
    "booking_error_already_cancelled": MessageLookupByLibrary.simpleMessage(
      "That booking is already cancelled",
    ),
    "booking_error_cancel_instead": MessageLookupByLibrary.simpleMessage(
      "You can still cancel this booking",
    ),
    "booking_error_appointment_passed": MessageLookupByLibrary.simpleMessage(
      "That appointment has passed",
    ),
    "account_info": MessageLookupByLibrary.simpleMessage("Account Info"),
    "appointments": MessageLookupByLibrary.simpleMessage("Appointments"),
    "available_days": MessageLookupByLibrary.simpleMessage("Available Days"),
    "available_time": MessageLookupByLibrary.simpleMessage("Available Time"),
    "birth_date": MessageLookupByLibrary.simpleMessage("Birth Date"),
    "book_now": MessageLookupByLibrary.simpleMessage("Book Now"),
    "booking_details": MessageLookupByLibrary.simpleMessage("Booking Details"),
    "cancel_booking": MessageLookupByLibrary.simpleMessage("Cancel Booking"),
    "change_password": MessageLookupByLibrary.simpleMessage("Change Password"),
    "city": MessageLookupByLibrary.simpleMessage("City"),
    "confirm_booking": MessageLookupByLibrary.simpleMessage("Confirm Booking"),
    "confirm_booking_payment": MessageLookupByLibrary.simpleMessage(
      "Confirm Booking & Payment",
    ),
    "confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "consultation_fee": MessageLookupByLibrary.simpleMessage(
      "Consultation Fee",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Create Account"),
    "currency": MessageLookupByLibrary.simpleMessage("EGP"),
    "discount": MessageLookupByLibrary.simpleMessage("Discount"),
    "doctors": MessageLookupByLibrary.simpleMessage("Doctors"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "email_address": MessageLookupByLibrary.simpleMessage("Email Address"),
    "email_hint": MessageLookupByLibrary.simpleMessage("example@mail.com"),
    "email_invalid_error": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email address",
    ),
    "email_locked_note": MessageLookupByLibrary.simpleMessage(
      "Your email is tied to your account and can\'t be changed here",
    ),
    "email_required_error": MessageLookupByLibrary.simpleMessage(
      "Email is required",
    ),
    "evening": MessageLookupByLibrary.simpleMessage("Evening"),
    "full_name": MessageLookupByLibrary.simpleMessage("Full Name"),
    "full_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter your full name",
    ),
    "governorate": MessageLookupByLibrary.simpleMessage("Governorate"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "instapay": MessageLookupByLibrary.simpleMessage("InstaPay"),
    "minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "morning": MessageLookupByLibrary.simpleMessage("Morning"),
    "name_min_error": MessageLookupByLibrary.simpleMessage(
      "Name must be at least 3 characters",
    ),
    "name_required_error": MessageLookupByLibrary.simpleMessage(
      "Name is required",
    ),
    "new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "password_hint": MessageLookupByLibrary.simpleMessage("••••••••"),
    "password_min_error": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters",
    ),
    "passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "pay_cash": MessageLookupByLibrary.simpleMessage("Pay Cash"),
    "payment": MessageLookupByLibrary.simpleMessage("Payment"),
    "payment_summary": MessageLookupByLibrary.simpleMessage("Payment Summary"),
    "personal_info": MessageLookupByLibrary.simpleMessage("Personal Info"),
    "phone_hint": MessageLookupByLibrary.simpleMessage("+20 01X XXXX XXXX"),
    "phone_invalid_error": MessageLookupByLibrary.simpleMessage(
      "Enter a valid phone number",
    ),
    "phone_number": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "phone_required_error": MessageLookupByLibrary.simpleMessage(
      "Phone number is required",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profile_updated_success": MessageLookupByLibrary.simpleMessage(
      "Changes saved successfully",
    ),
    "save_changes": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "select_appointment": MessageLookupByLibrary.simpleMessage(
      "Select Appointment",
    ),
    "select_birth_date": MessageLookupByLibrary.simpleMessage(
      "Select your birth date",
    ),
    "select_city": MessageLookupByLibrary.simpleMessage("Select City"),
    "select_governorate": MessageLookupByLibrary.simpleMessage(
      "Select Governorate",
    ),
    "select_location": MessageLookupByLibrary.simpleMessage(
      "Select Your Location",
    ),
    "select_payment_method": MessageLookupByLibrary.simpleMessage(
      "Select Payment Method",
    ),
    "specialties": MessageLookupByLibrary.simpleMessage("Specialties"),
    "total_amount": MessageLookupByLibrary.simpleMessage("Total Amount"),
    "update_profile": MessageLookupByLibrary.simpleMessage("Update Profile"),
    "vodafone_cash": MessageLookupByLibrary.simpleMessage("Vodafone Cash"),
    "waiting_time": MessageLookupByLibrary.simpleMessage("Waiting Time"),
    "your_appointment": MessageLookupByLibrary.simpleMessage(
      "Your Appointment",
    ),
    "your_next_appointment": MessageLookupByLibrary.simpleMessage(
      "Your Next Appointment",
    ),
  };
}
