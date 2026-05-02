// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Specialties`
  String get specialties {
    return Intl.message('Specialties', name: 'specialties', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Your Next Appointment`
  String get your_next_appointment {
    return Intl.message(
      'Your Next Appointment',
      name: 'your_next_appointment',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Appointments`
  String get appointments {
    return Intl.message(
      'Appointments',
      name: 'appointments',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Doctors`
  String get doctors {
    return Intl.message('Doctors', name: 'doctors', desc: '', args: []);
  }

  /// `Book Now`
  String get book_now {
    return Intl.message('Book Now', name: 'book_now', desc: '', args: []);
  }

  /// `Select Appointment`
  String get select_appointment {
    return Intl.message(
      'Select Appointment',
      name: 'select_appointment',
      desc: '',
      args: [],
    );
  }

  /// `Available Days`
  String get available_days {
    return Intl.message(
      'Available Days',
      name: 'available_days',
      desc: '',
      args: [],
    );
  }

  /// `Available Time`
  String get available_time {
    return Intl.message(
      'Available Time',
      name: 'available_time',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get morning {
    return Intl.message('Morning', name: 'morning', desc: '', args: []);
  }

  /// `Evening`
  String get evening {
    return Intl.message('Evening', name: 'evening', desc: '', args: []);
  }

  /// `Confirm Booking`
  String get confirm_booking {
    return Intl.message(
      'Confirm Booking',
      name: 'confirm_booking',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get payment {
    return Intl.message('Payment', name: 'payment', desc: '', args: []);
  }

  /// `Payment Summary`
  String get payment_summary {
    return Intl.message(
      'Payment Summary',
      name: 'payment_summary',
      desc: '',
      args: [],
    );
  }

  /// `Consultation Fee`
  String get consultation_fee {
    return Intl.message(
      'Consultation Fee',
      name: 'consultation_fee',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get total_amount {
    return Intl.message(
      'Total Amount',
      name: 'total_amount',
      desc: '',
      args: [],
    );
  }

  /// `Select Payment Method`
  String get select_payment_method {
    return Intl.message(
      'Select Payment Method',
      name: 'select_payment_method',
      desc: '',
      args: [],
    );
  }

  /// `Pay Cash`
  String get pay_cash {
    return Intl.message('Pay Cash', name: 'pay_cash', desc: '', args: []);
  }

  /// `Vodafone Cash`
  String get vodafone_cash {
    return Intl.message(
      'Vodafone Cash',
      name: 'vodafone_cash',
      desc: '',
      args: [],
    );
  }

  /// `InstaPay`
  String get instapay {
    return Intl.message('InstaPay', name: 'instapay', desc: '', args: []);
  }

  /// `Confirm Booking & Payment`
  String get confirm_booking_payment {
    return Intl.message(
      'Confirm Booking & Payment',
      name: 'confirm_booking_payment',
      desc: '',
      args: [],
    );
  }

  /// `Discount`
  String get discount {
    return Intl.message('Discount', name: 'discount', desc: '', args: []);
  }

  /// `Booking Details`
  String get booking_details {
    return Intl.message(
      'Booking Details',
      name: 'booking_details',
      desc: '',
      args: [],
    );
  }

  /// `Your Appointment`
  String get your_appointment {
    return Intl.message(
      'Your Appointment',
      name: 'your_appointment',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Booking`
  String get cancel_booking {
    return Intl.message(
      'Cancel Booking',
      name: 'cancel_booking',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_account {
    return Intl.message(
      'Create Account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get full_name {
    return Intl.message('Full Name', name: 'full_name', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Phone Number`
  String get phone_number {
    return Intl.message(
      'Phone Number',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Birth Date`
  String get birth_date {
    return Intl.message('Birth Date', name: 'birth_date', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Confirm Password`
  String get confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Select Your Location`
  String get select_location {
    return Intl.message(
      'Select Your Location',
      name: 'select_location',
      desc: '',
      args: [],
    );
  }

  /// `Governorate`
  String get governorate {
    return Intl.message('Governorate', name: 'governorate', desc: '', args: []);
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `Select City`
  String get select_city {
    return Intl.message('Select City', name: 'select_city', desc: '', args: []);
  }

  /// `Select Governorate`
  String get select_governorate {
    return Intl.message(
      'Select Governorate',
      name: 'select_governorate',
      desc: '',
      args: [],
    );
  }

  /// `Waiting Time`
  String get waiting_time {
    return Intl.message(
      'Waiting Time',
      name: 'waiting_time',
      desc: '',
      args: [],
    );
  }

  /// `EGP`
  String get currency {
    return Intl.message('EGP', name: 'currency', desc: '', args: []);
  }

  /// `Minutes`
  String get minutes {
    return Intl.message('Minutes', name: 'minutes', desc: '', args: []);
  }

  /// `Update Profile`
  String get update_profile {
    return Intl.message(
      'Update Profile',
      name: 'update_profile',
      desc: '',
      args: [],
    );
  }

  /// `Personal Info`
  String get personal_info {
    return Intl.message(
      'Personal Info',
      name: 'personal_info',
      desc: '',
      args: [],
    );
  }

  /// `Account Info`
  String get account_info {
    return Intl.message(
      'Account Info',
      name: 'account_info',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get change_password {
    return Intl.message(
      'Change Password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter your full name`
  String get full_name_hint {
    return Intl.message(
      'Enter your full name',
      name: 'full_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Name is required`
  String get name_required_error {
    return Intl.message(
      'Name is required',
      name: 'name_required_error',
      desc: '',
      args: [],
    );
  }

  /// `Name must be at least 3 characters`
  String get name_min_error {
    return Intl.message(
      'Name must be at least 3 characters',
      name: 'name_min_error',
      desc: '',
      args: [],
    );
  }

  /// `+20 01X XXXX XXXX`
  String get phone_hint {
    return Intl.message(
      '+20 01X XXXX XXXX',
      name: 'phone_hint',
      desc: '',
      args: [],
    );
  }

  /// `Phone number is required`
  String get phone_required_error {
    return Intl.message(
      'Phone number is required',
      name: 'phone_required_error',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid phone number`
  String get phone_invalid_error {
    return Intl.message(
      'Enter a valid phone number',
      name: 'phone_invalid_error',
      desc: '',
      args: [],
    );
  }

  /// `Select your birth date`
  String get select_birth_date {
    return Intl.message(
      'Select your birth date',
      name: 'select_birth_date',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get email_address {
    return Intl.message(
      'Email Address',
      name: 'email_address',
      desc: '',
      args: [],
    );
  }

  /// `example@mail.com`
  String get email_hint {
    return Intl.message(
      'example@mail.com',
      name: 'email_hint',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get email_required_error {
    return Intl.message(
      'Email is required',
      name: 'email_required_error',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address`
  String get email_invalid_error {
    return Intl.message(
      'Enter a valid email address',
      name: 'email_invalid_error',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_password {
    return Intl.message(
      'New Password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `••••••••`
  String get password_hint {
    return Intl.message('••••••••', name: 'password_hint', desc: '', args: []);
  }

  /// `Password must be at least 8 characters`
  String get password_min_error {
    return Intl.message(
      'Password must be at least 8 characters',
      name: 'password_min_error',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password`
  String get confirm_new_password {
    return Intl.message(
      'Confirm New Password',
      name: 'confirm_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwords_not_match {
    return Intl.message(
      'Passwords do not match',
      name: 'passwords_not_match',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get save_changes {
    return Intl.message(
      'Save Changes',
      name: 'save_changes',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
