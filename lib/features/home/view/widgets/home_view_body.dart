import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/home_features_grid.dart';
import '../../../home/presentation/widgets/last_read_card.dart';
import '../../../home/presentation/widgets/section_title.dart';
import '../../../home/presentation/widgets/islamic_content_grid.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          
          // Islamic features section
          const HomeFeaturesGrid(),
          
          // Quran section
        const LastReadCard(),
          
          // Islamic content section
      
          const IslamicContentGrid(),
          
          // Bottom spacing
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
