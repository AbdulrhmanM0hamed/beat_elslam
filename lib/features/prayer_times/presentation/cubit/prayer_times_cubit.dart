import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/prayer_times_repository.dart';
import '../../data/repositories/prayer_times_local_repository.dart';
import '../../services/prayer_reminder_service.dart';
import 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final PrayerTimesRepository _repository;
  final PrayerTimesLocalRepository _localRepository = PrayerTimesLocalRepository();
  final PrayerReminderService _reminderService = PrayerReminderService();

  PrayerTimesCubit(this._repository) : super(PrayerTimesInitial());

  Future<void> getPrayerTimes({
    String region = 'Cairo', 
    String country = 'EG'
  }) async {
    try {
      debugPrint('🔄 PrayerTimesCubit: Loading prayer times...');
      emit(PrayerTimesLoading());
      
      // تجاوز التحقق من الكاش والذهاب مباشرة للAPI
      debugPrint('🌐 PrayerTimesCubit: Fetching prayer times from API directly for $region, $country');
      
      // If cache is not available or needs update, fetch from API
      final prayerTimes = await _repository.getPrayerTimes(region, country);
      
      debugPrint('✅ PrayerTimesCubit: API returned prayer times');
      debugPrint('⏰ API data - Fajr: ${prayerTimes.prayerTimes.fajr}, Dhuhr: ${prayerTimes.prayerTimes.dhuhr}');
      
      // Cache the new data
      await _localRepository.savePrayerTimes(prayerTimes);
      
      // تهيئة خدمة العرض (بدون إشعارات)
      await _reminderService.initialize();
      
      emit(PrayerTimesLoaded(prayerTimes));
    } catch (e) {
      debugPrint('❌ PrayerTimesCubit error: $e');
      
      // التحقق من نوع الخطأ
      bool isNetworkError = false;
      if (e is DioException) {
        isNetworkError = e.type == DioExceptionType.connectionTimeout ||
                        e.type == DioExceptionType.connectionError ||
                        e.type == DioExceptionType.receiveTimeout ||
                        e.type == DioExceptionType.sendTimeout ||
                        (e.type == DioExceptionType.unknown && 
                         (e.message?.contains('SocketException') == true ||
                          e.message?.contains('Failed host lookup') == true ||
                          e.message?.contains('Network is unreachable') == true));
      } else {
        // للأخطاء الأخرى، تحقق من النص
        final errorMessage = e.toString().toLowerCase();
        isNetworkError = errorMessage.contains('socketexception') ||
                        errorMessage.contains('failed host lookup') ||
                        errorMessage.contains('network is unreachable') ||
                        errorMessage.contains('no internet') ||
                        errorMessage.contains('connection failed');
      }
      
      emit(PrayerTimesError(e.toString(), isNetworkError: isNetworkError));
    }
  }
} 