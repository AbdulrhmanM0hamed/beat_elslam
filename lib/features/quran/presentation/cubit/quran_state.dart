import 'package:equatable/equatable.dart';

class QuranState extends Equatable {
  final int currentPage;
  final bool isTableOfContentsVisible;
  
  const QuranState({
    this.currentPage = 1,
    this.isTableOfContentsVisible = true,
  });
  
  QuranState copyWith({
    int? currentPage,
    bool? isTableOfContentsVisible,
  }) {
    return QuranState(
      currentPage: currentPage ?? this.currentPage,
      isTableOfContentsVisible: isTableOfContentsVisible ?? this.isTableOfContentsVisible,
    );
  }
  
  @override
  List<Object> get props => [currentPage, isTableOfContentsVisible];
} 