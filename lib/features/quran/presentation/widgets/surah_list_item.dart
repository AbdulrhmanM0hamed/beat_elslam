import 'package:flutter/material.dart';
import '../../data/models/surah_model.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';

class SurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;
  final bool isCurrentlyReading;

  const SurahListItem({
    Key? key,
    required this.surah,
    required this.onTap,
    this.isCurrentlyReading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isCurrentlyReading 
              ? AppColors.primary.withOpacity(0.1) 
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Surah number
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah.id}',
                style: getSemiBoldStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Surah details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.name,
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.transliteration,
                    style: getRegularStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Type badge (Meccan/Medinan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: surah.isMakki 
                    ? Colors.amber.withOpacity(0.2) 
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: surah.isMakki ? Colors.amber : Colors.green,
                  width: 1,
                ),
              ),
              child: Text(
                surah.isMakki ? 'مكية' : 'مدنية',
                style: getMediumStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 10,
                  color: surah.isMakki ? Colors.amber[800] : Colors.green[800],
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Ayah count and page number
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${surah.totalVerses} آية',
                  style: getSemiBoldStyle(
                    fontFamily: FontConstant.cairo,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'صفحة ${surah.pageNumber}',
                  style: getMediumStyle(
                    fontFamily: FontConstant.cairo,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 