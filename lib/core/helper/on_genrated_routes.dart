import 'package:beat_elslam/features/home/view/home_View.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/azkar/presentation/screens/azkar_screen.dart';
import '../../features/azkar/presentation/screens/azkar_details_screen.dart';
import '../../features/azkar/models/azkar_model.dart';
import '../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../features/prayer_times/data/repositories/prayer_times_repository.dart';
import '../../features/qupla/presentation/screens/qupla_screen.dart';
import '../../features/masbaha/presentation/screens/masbaha_screen.dart';
import '../../features/quran/presentation/screens/quran_optimized_screen.dart';

Route<dynamic> onGenratedRoutes(RouteSettings settings) {
  switch (settings.name) {
    case HomeView.routeName:
      return MaterialPageRoute(builder: (context) => const HomeView());

    case '/azkar':
    case '/athkar':
      return MaterialPageRoute(builder: (context) => const AzkarScreen());

    case '/azkar-details':
      final category = settings.arguments as AzkarCategory;
      return MaterialPageRoute(
        builder: (context) => AzkarDetailsScreen(category: category),
      );

    case '/prayer-times':
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => PrayerTimesCubit(
            PrayerTimesRepositoryImpl(),
          ),
          child: const PrayerTimesScreen(),
        ),
      );

    case '/qibla':
    case '/qupla':
    case QuplaScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const QuplaScreen(),
      );
      
    case '/masabha':
      return MaterialPageRoute(
        builder: (context) => const MasbahaScreen(),
      );
      
    case '/quran':
    case QuranOptimizedScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const QuranOptimizedScreen(),
      );

    default:
      return MaterialPageRoute(builder: (context) => const HomeView());
  }
}
