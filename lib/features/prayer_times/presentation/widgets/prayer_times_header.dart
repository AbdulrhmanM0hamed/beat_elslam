import 'package:flutter/material.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../data/models/prayer_times_model.dart';

class PrayerTimesHeader extends StatelessWidget {
  final DateInfo dateInfo;
  final String location;

  const PrayerTimesHeader({
    Key? key,
    required this.dateInfo,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location
          const SizedBox(height: 24),

          // Title
          Align(
            alignment: Alignment.center,
            child: Text(
              '  مواقيت الصلاة  ',
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: FontSize.size24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Dates container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gregorian date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التاريخ الميلادي',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateInfo.dateEn,
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Divider
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),

                // Hijri date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'التاريخ الهجري',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          dateInfo.dateHijri.date,
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateInfo.dateHijri.weekday.ar,
                          style: getMediumStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
