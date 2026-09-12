import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shefaa_app/core/utils/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shefaa_app/core/utils/app_images.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/core/widgets/custom_mini_button.dart';
import 'package:shefaa_app/generated/l10n.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;
  final String location;
  final dynamic consultationFee;
  final String waitingTime;
  final double rating;

  /// Opens the doctor's page. The card body itself does nothing -- the two
  /// buttons are the only way out of it, so neither can be hit by accident
  /// while scrolling.
  final VoidCallback onDetailsTap;

  /// What "احجز الآن" does. Required, because a card that cannot say which
  /// doctor it shows must not be the thing deciding where the button goes --
  /// that is how it ended up opening the slots screen with no doctor at all.
  final VoidCallback onBookTap;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    this.rating = 4.5,
    required this.onDetailsTap, required this.location, required this.consultationFee, required this.waitingTime,
    required this.onBookTap,
  });

  /// consultation_fee is a Postgres numeric, so it arrives as a double and
  /// printed itself as "500.0". Nobody writes a clinic fee with a decimal.
  String get _fee {
    final fee = consultationFee;
    if (fee is num) return fee.toStringAsFixed(0);
    return '${fee ?? 0}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 255,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xffE8F3FF),
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
             const SizedBox(height: 12),

             Column(
              children: [
                Row(children: [

                  SvgPicture.asset(
  Assets.imagesMarker,
  width: 16,
  height: 16,
),
             const SizedBox(width: 6),

 Expanded(
                    child: Text(
                      location,
                      style: TextStyles.meduim14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                      
                ],),
                            const SizedBox(height: 12),

                Row(children: [

                  SvgPicture.asset(
  Assets.imagesMoney,
  width: 16,
  height: 16,
),
             const SizedBox(width: 6),

 Expanded(
                    child: Text(
                      "${S.of(context).consultation_fee}: $_fee ${S.of(context).currency}",
                      style: TextStyles.meduim14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                      
                ],),
                  const SizedBox(height: 12),

                Row(children: [

                  SvgPicture.asset(
  Assets.imagesClock,
  width: 16,
  height: 16,
),
             const SizedBox(width: 6),

 Expanded(
                    child: Text(
                      "${S.of(context).waiting_time}: $waitingTime ${S.of(context).minutes}",
                      style: TextStyles.meduim14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                      
                ],)
              ]),
            const SizedBox(height: 12),

            // Two taps that go to different places, so both are spelled out.
            // The whole card opens the doctor's page as well -- this row is
            // what says so, because a card that is silently tappable reads as
            // a card that does nothing.
            Row(
              children: [
                TextButton(
                  onPressed: onDetailsTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('عرض التفاصيل', style: TextStyles.meduim14),
                        const SizedBox(width: 2),
                        // Cupertino's chevron mirrors itself in a right to
                        // left layout, so it points the way the page opens.
                        const Icon(CupertinoIcons.chevron_forward, size: 14),
                      ],
                    ),
                  ),
                const Spacer(),
                CustomMiniButton(
                  title: S.of(context).book_now,
                  onPressed: onBookTap,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
