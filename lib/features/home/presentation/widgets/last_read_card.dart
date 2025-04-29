import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:beat_elslam/core/utils/constant/styles_manger.dart';
import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/quran/data/models/surah_model.dart';
import 'package:intl/intl.dart';
import '../../../../features/quran/presentation/cubit/quran_cubit.dart';

class LastReadCard extends StatefulWidget {
  final VoidCallback? onTap;

  const LastReadCard({super.key, this.onTap});

  @override
  State<LastReadCard> createState() => _LastReadCardState();
}

class _LastReadCardState extends State<LastReadCard> {
  bool _isLoading = true;
  String _surahName = '';
  String _surahNameArabic = '';
  int _pageNumber = 1;
  String _hijriDate = '';
  
  @override
  void initState() {
    super.initState();
    _loadLastReadData();
  }
  
  // Find the surah that contains the given page number
  Surah _findSurahByPageNumber(int pageNumber) {
    // Load all surahs and sort them by page number
    final List<Surah> orderedSurahs = List.from(SurahList.surahs)
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    
    // Find the last surah with a starting page number less than or equal to the given page
    for (int i = orderedSurahs.length - 1; i >= 0; i--) {
      if (orderedSurahs[i].pageNumber <= pageNumber) {
        // Check if this is the last surah
        if (i == orderedSurahs.length - 1) {
          return orderedSurahs[i];
        }
        
        // Check if the page is before the next surah starts
        if (pageNumber < orderedSurahs[i + 1].pageNumber) {
          return orderedSurahs[i];
        }
      }
    }
    
    // Default to the first surah if no match found
    return orderedSurahs.first;
  }
  
  Future<void> _loadLastReadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Use the consistent key from QuranCubit for the last read page
      final lastPage = prefs.getInt(QuranCubit.kLastReadPageKey) ?? 1;
      
      // Load all surahs
      await SurahList.loadSurahsPaginated(page: 1, pageSize: 114);
      
      // Find the surah based on the page number
      final surah = _findSurahByPageNumber(lastPage);
      
      // Get current Hijri date
      final hijri = HijriCalendar.now();
      final hijriMonth = hijri.hMonth;
      final hijriDay = hijri.hDay;
      final hijriYear = hijri.hYear;
      
      // Get month name in Arabic
      final List<String> hijriMonths = [
        'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة',
        'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
      ];
      
      setState(() {
        _pageNumber = lastPage;
        _surahName = surah.transliteration;
        _surahNameArabic = surah.name;
        _hijriDate = '${hijriMonths[hijriMonth - 1]} - $hijriDay-$hijriYear';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading last read data: $e');
      setState(() {
        _surahName = 'Al-Fatiha';
        _surahNameArabic = 'الفاتحة';
        _hijriDate = 'رمضان - ${DateFormat('dd-yyyy').format(DateTime.now())}';
        _isLoading = false;
      });
    }
  }
  
  // Method to navigate to the last read page
  void _navigateToLastReadPage(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Navigate to Quran screen with the page number
      Navigator.of(context).pushNamed('/quran', arguments: _pageNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToLastReadPage(context),
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.info,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Stack(
                children: [
                  // Date on top right
                  Positioned(
                    top: -5,
                    right: 10,
                    child: Container(
                      height: 35,
                      width: 150,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD336),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _hijriDate,
                            style: getBoldStyle(
                              fontFamily: FontConstant.cairo,
                              fontSize: FontSize.size13,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Left side content
                  Positioned(
                    top: 22,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Last read text
                        Row(
                          children: [
                            const Text(
                              'Last Read ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'آخر قراءة - صفحة $_pageNumber',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Surah name
                        Text(
                          '$_surahName - $_surahNameArabic',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Go to button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:const Row( 
                            mainAxisSize: MainAxisSize.min,
                            children:  [
                              Icon(Icons.arrow_back, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Go to',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lantern icon below date
                  Positioned(
                    bottom: 5,
                    right: 20,
                    child: Image.asset(
                      'assets/images/lantern.png',
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
