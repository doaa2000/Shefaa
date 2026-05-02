import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shefaa_app/core/enums/request_state.dart';
import 'package:shefaa_app/core/services/service_locator.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/utils/constants.dart';
import 'package:shefaa_app/core/widgets/custom_app_bar.dart';
import 'package:shefaa_app/core/widgets/custom_button.dart';
import 'package:shefaa_app/core/widgets/doctor_widget.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_event.dart';
import 'package:shefaa_app/features/bookings/presentation/bloc/bookings_state.dart';
import 'package:shefaa_app/features/payment/data/models/payment_args_model.dart';
import 'package:shefaa_app/features/payment/presentation/widgets/payment_screen_body.dart';
import 'package:shefaa_app/generated/l10n.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  static const String routeName = '/payment';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookingBloc>(),
      child: Scaffold(
        appBar: CustomAppBar(title: S.of(context).payment),
        body: PaymentScreenBody(),
      ),
    );
  }
}
