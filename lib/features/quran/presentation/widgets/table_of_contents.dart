import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/surah_model.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import 'surah_list_item.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';

class TableOfContents extends StatefulWidget {
  const TableOfContents({Key? key}) : super(key: key);

  @override
  State<TableOfContents> createState() => _TableOfContentsState();
}

class _TableOfContentsState extends State<TableOfContents> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadSurahData();
  }
  
  Future<void> _loadSurahData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Try the direct loading approach first - simplest and most reliable
      final surahs = await SurahList.loadAllSurahsDirectly();
      
      if (surahs.isEmpty) {
        // If direct approach failed, try the alternative methods
        await SurahList.loadSurahs();
        
        // If all else fails, try paginated loading
        if (SurahList.surahs.isEmpty) {
          await SurahList.loadSurahsPaginated(page: 1, pageSize: 114);
        }
      }
      
      // Debug log the results
      debugPrint('TableOfContents: Loaded ${SurahList.surahs.length} surahs');
    } catch (e) {
      debugPrint('TableOfContents: Error loading surahs: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<Surah> _getFilteredSurahs() {
    // If no surahs are loaded and we're still loading, return empty list
    // This prevents showing "No results" during loading
    if (_isLoading) {
      return [];
    }
    
    // If loading is done but surahs list is empty, force reload
    if (SurahList.surahs.isEmpty && !_isLoading) {
      // Trigger reload and return empty list for now
      Future.microtask(() => _loadSurahData());
      return [];
    }
    
    if (_searchQuery.isEmpty) {
      return SurahList.surahs;
    }
    
    return SurahList.surahs.where((surah) {
      final nameMatch = surah.name.contains(_searchQuery);
      final transliterationMatch = surah.transliteration.toLowerCase().contains(_searchQuery.toLowerCase());
      final translationMatch = surah.translation.toLowerCase().contains(_searchQuery.toLowerCase());
      final idMatch = surah.id.toString() == _searchQuery;
      
      return nameMatch || transliterationMatch || translationMatch || idMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        if (!state.isTableOfContentsVisible) {
          return const SizedBox.shrink();
        }
        
        final filteredSurahs = _getFilteredSurahs();
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primary,
                  child: Column(
                    children: [
                      Text(
                        'القرآن الكريم',
                        style: getBoldStyle(
                          fontFamily: FontConstant.cairo,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'فهرس السور',
                        style: getMediumStyle(
                          fontFamily: FontConstant.cairo,
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Search box
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'بحث عن سورة',
                      hintStyle: getRegularStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    textAlign: TextAlign.right,
                    style: getMediumStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                
                // Search results info
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${filteredSurahs.length} نتيجة بحث',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                
                // Loading or Surah list
                _isLoading 
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'جاري تحميل السور...',
                            style: getMediumStyle(
                              fontFamily: FontConstant.cairo,
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SurahList.surahs.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'حدث خطأ في تحميل السور',
                                style: getMediumStyle(
                                  fontFamily: FontConstant.cairo,
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadSurahData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: Text(
                                  'إعادة المحاولة',
                                  style: getMediumStyle(
                                    fontFamily: FontConstant.cairo,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: filteredSurahs.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد نتائج',
                                style: getMediumStyle(
                                  fontFamily: FontConstant.cairo,
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredSurahs.length,
                              itemBuilder: (context, index) {
                                final surah = filteredSurahs[index];
                                return SurahListItem(
                                  surah: surah,
                                  onTap: () {
                                    context.read<QuranCubit>().navigateToPage(surah.pageNumber);
                                  },
                                  isCurrentlyReading: _isCurrentlyReading(surah, state.currentPage),
                                );
                              },
                            ),
                      ),
                
                // Continue reading button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      // Use the new resumeReading method which handles all the logic internally
                      context.read<QuranCubit>().resumeReading();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'متابعة القراءة',
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  bool _isCurrentlyReading(Surah surah, int currentPage) {
    // Get all surahs in order
    final List<Surah> orderedSurahs = List.from(SurahList.surahs)
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    
    // Find the current surah's index
    final int surahIndex = orderedSurahs.indexWhere((s) => s.id == surah.id);
    if (surahIndex == -1) return false;
    
    // Get the current surah's page range
    final int startPage = surah.pageNumber;
    
    // If this is the last surah, its range extends to the end of the Quran
    if (surahIndex == orderedSurahs.length - 1) {
      return currentPage >= startPage;
    }
    
    // Get the next surah's starting page (which is the end of the current surah's range)
    final int endPage = orderedSurahs[surahIndex + 1].pageNumber - 1;
    
    // Check if the current page falls within this surah's range
    return currentPage >= startPage && currentPage <= endPage;
  }
} 