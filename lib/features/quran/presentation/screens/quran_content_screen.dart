import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/surah_model.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../widgets/table_of_contents.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';

/// A screen that displays the Quran content in a PDF viewer with RTL support
class QuranContentScreen extends StatefulWidget {
  const QuranContentScreen({Key? key}) : super(key: key);

  @override
  State<QuranContentScreen> createState() => _QuranContentScreenState();
}

class _QuranContentScreenState extends State<QuranContentScreen> with WidgetsBindingObserver {
  // UI States
  bool _isLoading = true;
  bool _showControls = false;
  
  // PDF States
  String? _pdfPath;
  int _currentPage = 1;
  int _totalPages = 604; // Total pages in Quran
  PDFViewController? _pdfViewController;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDocument();
    _loadSurahData();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release resources when app is in background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // PDF viewer handles memory management internally
    }
  }

  // Load the PDF from assets
  Future<void> _loadDocument() async {
    try {
      final ByteData data = await rootBundle.load('assets/pdf/quran.pdf');
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/quran.pdf');
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      
      setState(() {
        _pdfPath = tempFile.path;
      });
    } catch (e) {
      debugPrint('Error loading PDF: $e');
    }
  }

  // Initial data loading
  Future<void> _loadSurahData() async {
    await SurahList.loadSurahsPaginated(page: 1, pageSize: 40);
  }
  
  // Toggle control visibility with auto-hide
  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    
    // Auto-hide controls after 3 seconds
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls) setState(() => _showControls = false);
      });
    }
  }
  
  // Jump to a specific Quran page
  void _jumpToPage(int quranPageNumber) {
    if (quranPageNumber < 1 || quranPageNumber > _totalPages) return;
    
    debugPrint('Jumping to Quran page (original): $quranPageNumber');
    
    // استخدام الدالة المساعدة من QuranCubit للتحويل إلى فهرس PDF
    final pdfPageIndex = QuranCubit.convertToPdfIndex(quranPageNumber);
    
    debugPrint('PDF page index: $pdfPageIndex');
    
    _pdfViewController?.setPage(pdfPageIndex);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<QuranCubit, QuranState>(
        listener: (context, state) {
          // Only jump to page if PDF is loaded, TOC is not visible, and page changed in state
          if (!_isLoading && !state.isTableOfContentsVisible && 
              _currentPage != state.currentPage) {
            _jumpToPage(state.currentPage);
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // Loading indicator or PDF Viewer
                _pdfPath == null ? 
                  _buildLoadingIndicator() : 
                  _buildPdfViewer(context),
                
                // Custom AppBar overlay
                if (_showControls) _buildAppBar(context, state),
                
                // Table of Contents
                const TableOfContents(),
                
                // Bottom navigation bar
                if (_showControls && !_isLoading && !state.isTableOfContentsVisible)
                  _buildBottomNavBar(context, state),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Loading indicator widget
  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 70,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'جاري تجهيز المصحف...',
              style: getMediumStyle(
                fontFamily: FontConstant.cairo,
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
  
  // PDF Viewer widget
  Widget _buildPdfViewer(BuildContext context) {
    final cubit = context.read<QuranCubit>();
    final initialQuranPage = cubit.state.currentPage;
    final initialPdfPageIndex = QuranCubit.convertToPdfIndex(initialQuranPage);
    
    debugPrint('=== PDF Viewer Setup ===');
    debugPrint('Initial Quran page from cubit: $initialQuranPage');
    debugPrint('Initial PDF page index: $initialPdfPageIndex');
    debugPrint('Total pages: $_totalPages');
    
    return PDFView(
      filePath: _pdfPath!,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      defaultPage: initialPdfPageIndex,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (_pages) {
        debugPrint('PDF Rendered with ${_pages ?? 0} pages');
        setState(() {
          _isLoading = false;
          _totalPages = _pages!;
          
          // Get the current page from the cubit
          _currentPage = cubit.state.currentPage;
          debugPrint('Current page after render: $_currentPage');
        });
      },
      onError: (error) {
        debugPrint('PDF Error: $error');
      },
      onPageChanged: (int? pdfPageIndex, int? total) {
        if (pdfPageIndex != null && total != null) {
          // نحول من فهرس PDF إلى رقم صفحة قرآن أصلي
          final originalQuranPage = QuranCubit.convertFromPdfIndex(pdfPageIndex);
          
          debugPrint('PDF Page changed: index=$pdfPageIndex, converted to original Quran page=$originalQuranPage');
          
          setState(() {
            _currentPage = originalQuranPage;
          });
          
          // حفظ الصفحة في حالة الـ cubit
          cubit.onPageChanged(pdfPageIndex);
        }
      },
      onViewCreated: (PDFViewController controller) {
        _pdfViewController = controller;
        
        // Set initial page based on cubit state
        final initialQuranPage = cubit.state.currentPage;
        final initialPdfPageIndex = QuranCubit.convertToPdfIndex(initialQuranPage);
        
        debugPrint('PDF View Created:');
        debugPrint('Initial Quran page: $initialQuranPage');
        debugPrint('Initial PDF index: $initialPdfPageIndex');
        
        Future.delayed(const Duration(milliseconds: 100), () {
          _pdfViewController?.setPage(initialPdfPageIndex);
          debugPrint('Delayed setPage to $initialPdfPageIndex');
        });
      },
    );
  }
  
  // App bar overlay
  Widget _buildAppBar(BuildContext context, QuranState state) {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Container(
            height: 56,
            color: state.isTableOfContentsVisible 
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: state.isTableOfContentsVisible
                      ? () => Navigator.of(context).pop()
                      : () => context.read<QuranCubit>().toggleTableOfContents(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      state.isTableOfContentsVisible ? 'القرآن الكريم' : 'صفحة ${state.currentPage}',
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!state.isTableOfContentsVisible)
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => context.read<QuranCubit>().toggleTableOfContents(),
                    tooltip: 'عرض الفهرس',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Bottom navigation bar
  Widget _buildBottomNavBar(BuildContext context, QuranState state) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 60,
          color: Colors.black.withOpacity(0.6),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Next page button (right side in Arabic reading, moves to higher Quran page number)
                // In the reversed PDF, this means moving to a lower PDF page index
                _buildNavButton(
                  label: 'التالية',
                  icon: Icons.arrow_forward_ios,
                  iconFirst: true,
                  onPressed: () {
                    if (_pdfViewController != null) {
                      // Convert current Quran page to PDF index, then navigate to next Quran page
                      // Since PDF is reversed, we need to decrease the PDF page index to move forward in the Quran
                      final currentPdfPageIndex = QuranCubit.convertToPdfIndex(_currentPage);
                      // We check if there are pages before the current one (in a reversed context)
                      if (currentPdfPageIndex > 0) {
                        _pdfViewController!.setPage(currentPdfPageIndex - 1);
                      }
                    }
                  },
                  tooltip: 'الصفحة التالية',
                ),
                
                // Table of contents button
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => context.read<QuranCubit>().toggleTableOfContents(),
                  tooltip: 'الفهرس',
                ),
                
                // Page indicator and jump to page
                _buildPageIndicator(context, state),
                
                // Previous page button (left side in Arabic reading, moves to lower Quran page number)
                // In the reversed PDF, this means moving to a higher PDF page index
                _buildNavButton(
                  label: 'السابقة',
                  icon: Icons.arrow_back_ios,
                  iconFirst: false,
                  onPressed: () {
                    if (_pdfViewController != null) {
                      // Convert current Quran page to PDF index, then navigate to previous Quran page
                      // Since PDF is reversed, we need to increase the PDF page index to move backward in the Quran
                      final currentPdfPageIndex = QuranCubit.convertToPdfIndex(_currentPage);
                      // We check if there are pages after the current one (in a reversed context)
                      if (currentPdfPageIndex < _totalPages - 1) {
                        _pdfViewController!.setPage(currentPdfPageIndex + 1);
                      }
                    }
                  },
                  tooltip: 'الصفحة السابقة',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Navigation button (next/previous)
  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required bool iconFirst,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final children = [
      Text(
        label,
        style: getRegularStyle(
          fontFamily: FontConstant.cairo,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 2),
      Icon(icon, color: Colors.white, size: 16),
    ];
    
    return IconButton(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: iconFirst ? children.reversed.toList() : children,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
  
  // Page indicator with jump functionality
  Widget _buildPageIndicator(BuildContext context, QuranState state) {
    return InkWell(
      onTap: () => _showJumpToPageDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'صفحة ${state.currentPage}',
          style: getMediumStyle(
            fontFamily: FontConstant.cairo,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  // Jump to page dialog
  void _showJumpToPageDialog(BuildContext context) {
    final TextEditingController pageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'الانتقال إلى صفحة',
          style: getBoldStyle(
            fontFamily: FontConstant.cairo,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'رقم الصفحة (1-${_totalPages})',
            hintStyle: getRegularStyle(
              fontFamily: FontConstant.cairo,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: getMediumStyle(
                fontFamily: FontConstant.cairo,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNumber = int.tryParse(pageController.text);
              if (pageNumber != null && pageNumber >= 1 && pageNumber <= _totalPages) {
                _jumpToPage(pageNumber);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'انتقال',
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 