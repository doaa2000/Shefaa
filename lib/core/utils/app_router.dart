// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mroonah_care/cart/presentation/screens/cart_screen.dart';

// import 'package:mroonah_care/core/enums/booking_source.dart';
// import 'package:mroonah_care/core/helper_functions/route_observer.dart';
// import 'package:mroonah_care/features/add_address/presentation/views/add_address_view.dart';
// import 'package:mroonah_care/features/auth/presentation/view/register_view.dart';
// import 'package:mroonah_care/features/auth/presentation/view/widgets/create_new_password_screen.dart';
// import 'package:mroonah_care/features/auth/presentation/view/widgets/send_code_via_email_view.dart';
// import 'package:mroonah_care/features/bottom_nav_bar/bottom_nav_bar_view.dart';
// import 'package:mroonah_care/features/create_booking/data/models/booking_model/booking_model.dart';
// import 'package:mroonah_care/features/home/presentaion/views/home_view.dart';
// import 'package:mroonah_care/features/home/presentaion/views/widgets/ad_services_view.dart';
// import 'package:mroonah_care/features/my_booking/data/models/my_booking_model/row.dart';
// import 'package:mroonah_care/features/my_booking/presentation/views/my_booking_view.dart';
// import 'package:mroonah_care/features/notifications/data/models/my_inquiries_model/my_inquiries_model.dart';
// import 'package:mroonah_care/features/notifications/presentation/notifications_view.dart';
// import 'package:mroonah_care/features/payment/presentation/payment_view.dart';
// import 'package:mroonah_care/features/payment/presentation/widgets/card_payment_view.dart';
// import 'package:mroonah_care/features/payment/presentation/widgets/payment_error_screen.dart';
// import 'package:mroonah_care/features/payment/presentation/widgets/payment_success_screen.dart';
// import 'package:mroonah_care/features/profile/presentation/views/profile_view.dart';
// import 'package:mroonah_care/features/saved_addresses/presentation/view/saved_addresses_view.dart';
// import 'package:mroonah_care/features/saved_addresses/presentation/view/widgets/no_saved_addresses_widget.dart';
// import 'package:mroonah_care/features/sub_service/presentation/views/sub_service_view.dart';
// import 'package:mroonah_care/features/on_boarding/presentaion/views/on_boarding_view.dart';
// import 'package:mroonah_care/features/splash/presenation/views/splash_view.dart';
// import 'package:mroonah_care/features/health_cares/presentation/views/health_care_view.dart';
// import 'package:mroonah_care/features/support/presentation/views/support_view.dart';

// final rootNavigatorKey = GlobalKey<NavigatorState>();

// abstract class AppRouter {
//   static const kSplashView = '/splashView';
//   static const kOnBoardingView = '/onBoardingView';
//   static const kRegisterView = '/registerView';
//   static const kBottomNavBarView = '/bottomNavBarView';
//   static const kHomeView = '/homeView';
//   static const kProfileView = '/profileView';
//   static const kSendCodeViaEmailView = '/sendCodeViaEmailView';
//   static const kCreateNewPasswordScreen = '/createNewPasswordScreen';
//   static const kNotificationsView = '/notificationsView';
//   static const kSubServiceView = '/subServiceView';
//   static const kAdServicesView = '/adServicesView';
//   static const kSavedAddressesView = '/savedAddressesView';
//   static const kHealthCaresView = '/healthCaresView';
//   static const kAddAddressView = '/addAddressView';
//   static const kPaymentView = '/paymentView';
//   static const kNoSavedAddressesWidget = '/noSavedAddressesWidget';
//   static const kPaymentSuccessScreen = '/paymentSuccessScreen';
//   static const kPaymentErrorScreen = '/paymentErrorScreen';
//   static const kMyBookingView = '/myBookingView';
//   static const kGateWayView = '/gateWayView';
//   static const kSupportView = '/supportView';
//     static const kCartScreen = '/cartScreen';

//   static final router = GoRouter(
//     navigatorKey: rootNavigatorKey,
//     observers: [
//       routeObserver,
//       FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
//     ],
//     routes: [
//       GoRoute(
//         path:'/',
//         builder: (context, state) => const SplashView(),
//       ),
//       GoRoute(
//         path: kOnBoardingView,
//         builder: (context, state) => const OnBoardingView(),
//       ),
//       GoRoute(
//         path: kRegisterView,
//         builder: (context, state) => const RegisterView(),
//       ),
//       GoRoute(
//         path: kBottomNavBarView,
//         builder: (context, state) => const BottomNavBarView(),
//       ),
//       GoRoute(
//         path: kHomeView,
//         builder: (context, state) => const HomeView(),
//       ),
//       GoRoute(
//         path: kProfileView,
//         builder: (context, state) => const ProfileView(),
//       ),
//       GoRoute(
//         path: kSendCodeViaEmailView,
//         builder: (context, state) => const SendCodeViaEmailView(),
//       ),
//       GoRoute(
//         path: kCreateNewPasswordScreen,
//         builder: (context, state) => const CreateNewPasswordScreen(),
//       ),
//       GoRoute(
//         path: kNotificationsView,
//         builder: (context, state) {
//           final model = state.extra as MyInquiriesModel?;
//           return NotificationsView(myInquiriesModel: model);
//         },
//       ),
//       GoRoute(
//         path: kSubServiceView,
//         builder: (context, state) {
//           final args = state.extra as Map<String, dynamic>?;
//           return SubServiceView(
//             serviceId: args?['serviceId'] as int?,
//           );
//         },
//       ),
//       GoRoute(
//         path: kAdServicesView,
//         builder: (context, state) {
//           final args = state.extra as Map<String, dynamic>?;
//           return AdServicesView(
//             item: args?['adsService'],
//           );
//         },
//       ),
//       GoRoute(
//         path: kSavedAddressesView,
//         builder: (context, state) => const SavedAddressesView(),
//       ),
//       GoRoute(
//         path: kHealthCaresView,
//         builder: (context, state) => const HealthCaresView(
//           bookingSource: BookingSource.normalService,
//           serviceAccessId: 0,
//         ),
//       ),
//       GoRoute(
//         path: kAddAddressView,
//         builder: (context, state) => const AddAddressView(),
//       ),
//       GoRoute(
//         path: kPaymentView,
//         builder: (context, state) {
//           final bookingId = state.extra as int;
//           return PaymentView(bookingId: bookingId);
//         },
//       ),
//       GoRoute(
//         path: kNoSavedAddressesWidget,
//         builder: (context, state) => const NoSavedAddressesWidget(),
//       ),
//       GoRoute(
//         path: kPaymentSuccessScreen,
//         builder: (context, state) => const PaymentSuccessScreen(),
//       ),
//       GoRoute(
//         path: kPaymentErrorScreen,
//         builder: (context, state) => const PaymentErrorScreen(),
//       ),
//       GoRoute(
//         path: kMyBookingView,
//         builder: (context, state) => const MyBookingView(),
//       ),
//       GoRoute(
//         path: kGateWayView,
//         builder: (context, state) {
//           final bookings = state.extra as List<BookingItem>? ?? [];
//           return GateWayView(bookingModel: bookings);
//         },
//       ),
//       GoRoute(
//         path: kSupportView,
//         builder: (context, state) => const SupportView(),
//       ),
//          GoRoute(
//         path: kCartScreen,
//         builder: (context, state) => const CartScreen(),
//       ),
//     ],
//   );
// }
