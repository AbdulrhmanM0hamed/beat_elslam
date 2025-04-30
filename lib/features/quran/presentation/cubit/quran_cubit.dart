import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_state.dart';

/// ملاحظة مهمة حول نظام ترقيم الصفحات في هذا التطبيق:
/// ------------------------------------------------------
/// 1. ملف PDF الخاص بالقرآن معكوس:
///    - الصفحة الأولى في الـ PDF هي في الواقع آخر صفحة في القرآن (ص 604)
///    - الصفحة الأخيرة في الـ PDF هي في الواقع أول صفحة في القرآن (ص 1)
///
/// 2. أرقام الصفحات المستخدمة في هذا التطبيق:
///    - "رقم الصفحة الأصلي" (Original): يشير إلى ترقيم الصفحات المعتاد في القرآن (1-604)
///    - "رقم الصفحة المعكوس" (Reversed): يشير إلى ترقيم الصفحات في الـ PDF المعكوس
///      (معادلة التحويل: معكوس = 605 - أصلي)
///
/// 3. استخدام الأرقام في التطبيق:
///    - state.currentPage: يخزن دائماً رقم صفحة أصلي (1-604)
///    - للتعامل مع PDF نستخدم convertToReversedPage و convertToPdfIndex

/// Manages the state for the Quran screen, including navigation,
/// table of contents visibility, and reading position tracking.
class QuranCubit extends Cubit<QuranState> {
  // Constants
  static const String kLastReadPageKey = 'quran_last_read_page';
  static const int kTotalPages = 604;
  static const int kDefaultPage = 1;
  
  QuranCubit() : super(const QuranState()) {
    _loadReadingPosition();
  }
  
  /// تحويل من رقم صفحة أصلي (1-604) إلى رقم صفحة معكوس للـ PDF
  static int convertToReversedPage(int originalPage) {
    return 605 - originalPage;
  }
  
  /// تحويل من رقم صفحة معكوس إلى رقم صفحة أصلي
  static int convertToOriginalPage(int reversedPage) {
    return 605 - reversedPage;
  }
  
  /// تحويل من رقم صفحة أصلي إلى مؤشر PDF (0-based)
  static int convertToPdfIndex(int originalPage) {
    // أولاً: نحول إلى رقم معكوس
    int reversedPage = convertToReversedPage(originalPage);
    // ثانياً: نحول إلى مؤشر PDF (0-based)
    return reversedPage - 1;
  }
  
  /// تحويل من مؤشر PDF (0-based) إلى رقم صفحة أصلي
  static int convertFromPdfIndex(int pdfIndex) {
    // أولاً: نحول إلى رقم صفحة معكوس (1-based)
    int reversedPage = pdfIndex + 1;
    // ثانياً: نحول إلى رقم صفحة أصلي
    return convertToOriginalPage(reversedPage);
  }
  
  /// Loads the user's last reading position from local storage
  Future<void> _loadReadingPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt(kLastReadPageKey);
      
      // Use a valid page number or default to page 1
      final pageNumber = _validatePageNumber(lastPage);
      
      print('Loading reading position: $pageNumber (original page)');
      
      emit(state.copyWith(currentPage: pageNumber));
    } catch (e) {
      print('Error loading reading position: $e');
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
      
      // تسجيل للتصحيح
      print('Saving reading position: ${state.currentPage} (original page)');
      
      // تنفيذ الحفظ فوراً واستخدام await للتأكد من إكماله
      await prefs.setInt(kLastReadPageKey, state.currentPage);
      
      print('Reading position saved successfully');
    } catch (e) {
      print('Error saving reading position: $e');
    }
  }
  
  /// Navigates to a specific page in the Quran
  void navigateToPage(int originalPageNumber) {
    // Validate the page number before navigation
    final validPage = _validatePageNumber(originalPageNumber);
    
    // تسجيل للتصحيح
    print('Navigate to page: $validPage (original page)');
    print('  In PDF: index=${convertToPdfIndex(validPage)}');
    
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
  void onPageChanged(int pdfPageIndex) {
    // تحويل من مؤشر PDF إلى رقم صفحة أصلي
    final originalPage = convertFromPdfIndex(pdfPageIndex);
    
    // Only update if the page actually changed
    if (originalPage != state.currentPage) {
      // تسجيل للتصحيح
      print('PDF Page changed: index=$pdfPageIndex');
      print('  Converting to original page: $originalPage');
      
      emit(state.copyWith(currentPage: originalPage));
      _saveReadingPosition();
    }
  }
  
  /// Resumes reading from the last saved position
  Future<void> resumeReading() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // استخدام getInt مع التعامل مع القيمة الافتراضية
      final lastPage = prefs.getInt(kLastReadPageKey) ?? kDefaultPage;
      
      print('Resume Reading: Last saved page: $lastPage (original page)');
      
      // لأننا نخزن الرقم الأصلي، يمكننا استخدامه مباشرة
      navigateToPage(lastPage);
    } catch (e) {
      print('Error in resumeReading: $e');
      // If error occurs, navigate to default page
      navigateToPage(kDefaultPage);
    }
  }
  
  /// الحصول على مؤشر PDF (0-based) للصفحة الحالية
  int getCurrentPdfIndex() {
    return convertToPdfIndex(state.currentPage);
  }
  
  @override
  Future<void> close() {
    _saveReadingPosition();
    return super.close();
  }
} 