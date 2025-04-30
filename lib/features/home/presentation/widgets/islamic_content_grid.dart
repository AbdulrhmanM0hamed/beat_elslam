import 'package:flutter/material.dart';
import 'content_card.dart';

class IslamicContentGrid extends StatelessWidget {
  const IslamicContentGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8, // Make cards slightly taller than wide
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Quran Card
          ContentCard(
            title: 'القرآن الكريم',
            iconPath: 'assets/images/mushaf_1.png',
            cardColor: const Color(0xFF4CBECD),
            onTap: () {
              Navigator.pushNamed(context, '/quran');
            },
          ),
          
          // Hadith Card
          ContentCard(
            title: 'حديث',
            iconPath: 'assets/images/moon.png',
            cardColor: const Color(0xFFB17AD8),
            onTap: () {
              Navigator.pushNamed(context, '/hadith');
            },
          ),
          
          // Tafsir Card
          ContentCard(
            title: 'تفسير',
            iconPath: 'assets/images/mushaf.png',
            cardColor: const Color(0xFFE678AE),
            onTap: () {
              Navigator.pushNamed(context, '/tafsir');
            },
          ),
          
          // Names of Allah Card - تحسين مظهر كارت أسماء الله الحسنى
          ContentCard(
            title: 'أسماء الله الحسنى',
            iconPath: 'assets/images/moon.png', // استخدام صورة القمر بدلاً من الصورة المفقودة
            cardColor: const Color.fromARGB(255, 74, 137, 168), // لون داكن راقي يناسب أهمية المحتوى
            onTap: () {
              Navigator.pushNamed(context, '/asma-allah');
            },
          ),
        ],
      ),
    );
  }
} 