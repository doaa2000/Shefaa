import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shefaa_app/core/utils/app_images.dart';
import 'package:shefaa_app/core/utils/app_text_styles.dart';
import 'package:shefaa_app/generated/l10n.dart';

class DoctorDetailsWidget extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;
  final String location;
  final dynamic consultationFee;
  final String waitingTime;
  final double rating;
  final VoidCallback? onTap;

  const DoctorDetailsWidget({
    super.key,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    this.rating = 4.5,
    this.onTap, required this.location, required this.consultationFee, required this.waitingTime,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 215,
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

 Text(
                        location,
                        style: TextStyles.meduim14,
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

 Text(
                        "${S.of(context).consultation_fee}: $consultationFee ${S.of(context).currency}",
                        style: TextStyles.meduim14,
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

 Text(
                        "${S.of(context).waiting_time}: $waitingTime ${S.of(context).minutes}",
                        style: TextStyles.meduim14,
                      ),

                      
                ],)
              ]),
            const SizedBox(height: 12),

          
          ],
        ),
      ),
    );
  }
}
