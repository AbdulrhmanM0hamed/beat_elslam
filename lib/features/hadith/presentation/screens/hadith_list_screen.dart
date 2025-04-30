import 'package:flutter/material.dart';
import '../../models/hadith_model.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_theme.dart';

class HadithListScreen extends StatelessWidget {
  final HadithCollection collection;

  const HadithListScreen({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          collection.sectionName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: collection.hadiths.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.book_outlined,
                      size: 70,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'لا توجد أحاديث متاحة في هذا القسم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customColors?.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: collection.hadiths.length,
                itemBuilder: (context, index) {
                  final hadith = collection.hadiths[index];
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: customColors?.cardContentBg ?? Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header with colored background
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: customColors?.cardHeaderBg ?? AppColors.primary.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  topLeft: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${hadith.hadithNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'حديث شريف',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: customColors?.textPrimary ?? Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (hadith.grades.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getGradeColor(hadith.grades.first.grade),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        hadith.grades.first.grade,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hadith.text,
                                    style: TextStyle(
                                      fontSize: 18,
                                      height: 1.8,
                                      fontWeight: FontWeight.w500,
                                      color: customColors?.textPrimary ?? Colors.black87,
                                    ),
                                    textAlign: TextAlign.justify,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  if (hadith.reference.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    const Divider(height: 1),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: customColors?.timeContainerBg ?? Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: customColors?.timeContainerBorder ?? Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.bookmark_outlined,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              hadith.reference,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: customColors?.textSecondary ?? Colors.grey.shade700,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    final lowerGrade = grade.toLowerCase();
    if (lowerGrade.contains('صحيح') || lowerGrade == 'sahih') {
      return Colors.green.shade700;
    } else if (lowerGrade.contains('حسن') || lowerGrade == 'hasan') {
      return Colors.blue.shade700;
    } else if (lowerGrade.contains('ضعيف') || lowerGrade == 'da\'if') {
      return Colors.orange.shade700;
    } else if (lowerGrade.contains('موضوع') || lowerGrade == 'maudu') {
      return Colors.red.shade700;
    }
    return Colors.grey.shade700;
  }
} 