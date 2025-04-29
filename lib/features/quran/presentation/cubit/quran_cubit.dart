import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_state.dart';

/// Manages the state for the Quran screen, including navigation,
/// table of contents visibility, and reading position tracking.
class QuranCubit extends Cubit<QuranState> {
  // Constants
  static const String kLastReadPageKey = 'last_read_page';
  static const int kTotalPages = 604;
  static const int kDefaultPage = 1;
  
  QuranCubit() : super(const QuranState()) {
    _loadReadingPosition();
  }
  
  /// Loads the user's last reading position from local storage
  Future<void> _loadReadingPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt(kLastReadPageKey);
      
      // Use a valid page number or default to page 1
      final pageNumber = _validatePageNumber(lastPage);
      
      emit(state.copyWith(currentPage: pageNumber));
    } catch (e) {
      // Silently handle errors and use default page
      emit(state.copyWith(currentPage: kDefaultPage));
    }
  }
  
  /// Validates and normalizes a page number to ensure it's within valid range
  int _validatePageNumber(int? page) {
    // If no stored page or invalid page, use default
    if (page == null || page < 1) {
      return kDefaultPage;
    }
    
    // Ensure page is not beyond the total pages
    if (page > kTotalPages) {
      return kTotalPages;
    }
    
    return page;
  }
  
  /// Saves the current reading position to local storage
  Future<void> _saveReadingPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(kLastReadPageKey, state.currentPage);
    } catch (e) {
      // Silently handle errors
    }
  }
  
  /// Navigates to a specific page in the Quran
  void navigateToPage(int pageNumber) {
    // Validate the page number before navigation
    final validPage = _validatePageNumber(pageNumber);
    
    emit(state.copyWith(
      currentPage: validPage,
      isTableOfContentsVisible: false, // Hide TOC when navigating
    ));
    
    _saveReadingPosition();
  }
  
  /// Toggles the visibility of the table of contents
  void toggleTableOfContents() {
    emit(state.copyWith(
      isTableOfContentsVisible: !state.isTableOfContentsVisible,
    ));
  }
  
  /// Called when page changes from user swiping or other navigation
  void onPageChanged(int pageNumber) {
    // Only update if the page actually changed
    if (pageNumber != state.currentPage) {
      emit(state.copyWith(currentPage: pageNumber));
      _saveReadingPosition();
    }
  }
  
  /// Resumes reading from the last saved position
  Future<void> resumeReading() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt(kLastReadPageKey) ?? kDefaultPage;
      
      navigateToPage(lastPage);
    } catch (e) {
      // If error occurs, navigate to default page
      navigateToPage(kDefaultPage);
    }
  }
  
  @override
  Future<void> close() {
    _saveReadingPosition();
    return super.close();
  }
} 