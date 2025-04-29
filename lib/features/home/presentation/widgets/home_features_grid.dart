import 'package:flutter/material.dart';
import '../../../../core/utils/constant/assets_manager.dart';
import 'feature_item.dart';

class HomeFeaturesGrid extends StatelessWidget {
  const HomeFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: const [
          FeatureItem(
            icon: AssetsManager.pngtreeImage,
            title: 'المسبحة',
            routeName: '/masabha',
            color: Color(0xFF83B783), // Green shade
          ),
          FeatureItem(
            icon: AssetsManager.qiblahImage,
            title: 'القبلة',
            routeName: '/qupla',
            color: Color(0xFFC89B7B), // Brown shade
          ),
          FeatureItem(
            icon: AssetsManager.ramadanImage,
            title: 'مواقيت الصلاة',
            routeName: '/prayer-times',
            color: Color(0xFF7B90C8), // Blue shade
          ),
          FeatureItem(
            icon: AssetsManager.azkarImage,
            title: 'الاذكار',
            routeName: '/athkar',
            color: Color(0xFFC87B7B), // Red shade
          ),
        ],
      ),
    );
  }
}