import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:beat_elslam/core/utils/constant/styles_manger.dart';
import 'package:beat_elslam/features/asma_allah/data/repositories/allah_names_repository.dart';
import 'package:beat_elslam/features/asma_allah/presentation/cubit/asma_allah_cubit.dart';
import 'package:beat_elslam/features/asma_allah/presentation/screens/asma_allah_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class FeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String routeName;
  final Color color;
  final Logger _logger = Logger();

  FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.routeName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _logger.i('Tapped on feature: $title with route: $routeName');
        
        // استخدام نهج خاص لميزة أسماء الله الحسنى
        if (routeName == '/asma-allah') {
          _logger.i('Using direct navigation for Asma Allah feature');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => AsmaAllahCubit(
                  AllahNamesRepositoryImpl(),
                ),
                child: const AsmaAllahScreen(),
              ),
            ),
          );
        } else {
          // استخدام نظام التنقل العادي لباقي الميزات
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Container(
        width: 80,
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    icon,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: FontSize.size12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 