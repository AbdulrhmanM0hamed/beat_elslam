import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_times_model.dart';

abstract class PrayerTimesRepository {
  Future<PrayerTimesResponse> getPrayerTimes(String region, String country);
}

class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  final Dio _dio;

  PrayerTimesRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<PrayerTimesResponse> getPrayerTimes(String region, String country) async {
    try {
      // التحقق من أذونات الموقع قبل الاتصال بالـ API
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('🔍 Location permission denied. Requesting permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('🔍 Location permission denied after request');
          return _getDefaultPrayerTimes(region, country);
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('🔍 Location permission denied forever');
        return _getDefaultPrayerTimes(region, country);
      }

      // الحصول على التاريخ الحالي بتنسيق DD-MM-YYYY
      final now = DateTime.now();
      final currentDate = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      
      debugPrint('🔍 Calling API with region: $region, country: $country');
      debugPrint('📅 Using date: $currentDate');
      
      // استخدام API جديد وموثوق مع العنوان والتاريخ
      final response = await _dio.get(
        'https://api.aladhan.com/v1/timingsByAddress/$currentDate',
        queryParameters: {
          'address': '$region,$country',
          'method': 8, // Gulf Region method (أو يمكن استخدام 5 للطريقة المصرية)
        },
      );

      debugPrint('✅ API response status: ${response.statusCode}');
      debugPrint('📊 API response data: ${response.data}');

      if (response.statusCode == 200) {
        final result = PrayerTimesResponse.fromJson(response.data);
        debugPrint('⏰ Prayer times parsed - Fajr: ${result.prayerTimes.fajr}, Dhuhr: ${result.prayerTimes.dhuhr}');
        
        // تحقق من أن الأوقات ليست فارغة
        if (result.prayerTimes.fajr.isEmpty || 
            result.prayerTimes.dhuhr.isEmpty || 
            result.prayerTimes.asr.isEmpty || 
            result.prayerTimes.maghrib.isEmpty || 
            result.prayerTimes.isha.isEmpty) {
          debugPrint('⚠️ API returned empty prayer times, using default values');
          return _getDefaultPrayerTimes(region, country);
        }
        
        // تحديث region و country بالقيم الصحيحة
        final updatedResult = PrayerTimesResponse(
          region: region,
          country: country,
          prayerTimes: result.prayerTimes,
          date: result.date,
          meta: result.meta,
        );
        
        return updatedResult;
      } else {
        debugPrint('❌ API returned non-200 status code: ${response.statusCode}');
        // إذا فشلت الاستجابة، استخدم البيانات الافتراضية
        return _getDefaultPrayerTimes(region, country);
      }
    } catch (e) {
      debugPrint('❌ Error calling API: $e');
      // السماح بانتشار أخطاء الشبكة للتعامل معها في واجهة المستخدم
      if (e is DioException && 
          (e.type == DioExceptionType.connectionTimeout || 
           e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.unknown)) {
        // إعادة إلقاء أخطاء الشبكة ليتم عرض رسالة عدم الاتصال
        throw e;
      }
      // للأخطاء الأخرى، استخدم البيانات الافتراضية
      return _getDefaultPrayerTimes(region, country);
    }
  }
  
  // إضافة طريقة للحصول على بيانات افتراضية لمواقيت الصلاة
  PrayerTimesResponse _getDefaultPrayerTimes(String region, String country) {
    final now = DateTime.now();
    final String today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    return PrayerTimesResponse(
      region: region,
      country: country,
      prayerTimes: const PrayerTimes(
        fajr: "04:30",
        sunrise: "06:00",
        dhuhr: "12:10",
        asr: "15:30",
        maghrib: "18:10",
        isha: "19:40",
      ),
      date: DateInfo(
        dateEn: today,
        dateHijri: HijriDate(
          date: today,
          format: "DD-MM-YYYY",
          day: "${now.day}",
          weekday: const Weekday(
            en: "Friday",
            ar: "الجمعة",
          ),
          month: const Month(
            number: 9,
            en: "Ramadan",
            ar: "رمضان",
            days: 30,
          ),
          year: "${DateTime.now().year - 579}",
        ),
      ),
      meta: const Meta(
        timezone: "Africa/Cairo",
      ),
    );
  }
} 