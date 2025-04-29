import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class Surah {
  final int id;
  final String name;
  final String transliteration;
  final String translation;
  final String type;
  final int totalVerses;
  int pageNumber;

  Surah({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.translation,
    required this.type,
    required this.totalVerses,
    required this.pageNumber,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      name: json['name'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      type: json['type'],
      totalVerses: json['total_verses'],
      pageNumber: json['id'],
    );
  }

  bool get isMakki => type == 'meccan';
}

class SurahList {
  static List<Surah> surahs = [];
  static List<dynamic> rawJsonData = [];
  static bool jsonLoaded = false;
  static bool _isLoading = false;
  static Map<int, List<Surah>> _cachedPagedSurahs = {}; // Cache for paginated results
  
  // Pre-initialize the JSON data at app start but without blocking
  static void preInitialize() {
    loadJsonData();
  }
  
  static Future<void> loadJsonData() async {
    if (jsonLoaded || _isLoading) {
      debugPrint('SurahList: JSON data already loaded or loading in progress');
      return;
    }
    
    _isLoading = true;
    try {
      // Load the JSON data from the assets file
      debugPrint('SurahList: Loading JSON data from assets');
      final String jsonString = await rootBundle.loadString('assets/json/name_quran.json');
      rawJsonData = json.decode(jsonString);
      jsonLoaded = true;
      debugPrint('SurahList: JSON data loaded successfully with ${rawJsonData.length} items');
    } catch (e) {
      rawJsonData = [];
      jsonLoaded = false;
      debugPrint('SurahList: Error loading surah data: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  static Future<List<Surah>> loadSurahs() async {
    if (!jsonLoaded) {
      debugPrint('SurahList: JSON not loaded, loading now...');
      await loadJsonData();
    }

    if (surahs.isEmpty && rawJsonData.isNotEmpty) {
      // Process in a separate isolate to avoid UI freezes
      debugPrint('SurahList: Processing surahs from raw data...');
      surahs = await compute(_processSurahsFromJsonIsolate, rawJsonData);
      debugPrint('SurahList: Processed ${surahs.length} surahs');
    } else {
      debugPrint('SurahList: Surahs already loaded (${surahs.length}) or raw data is empty (${rawJsonData.length})');
    }

    return surahs;
  }
  
  // For processing in a separate isolate
  static List<Surah> _processSurahsFromJsonIsolate(List<dynamic> data) {
    return _processAndReturnSurahs(data);
  }
  
  static Future<List<Surah>> loadSurahsPaginated({required int page, required int pageSize}) async {
    if (!jsonLoaded) {
      await loadJsonData();
    }

    if (rawJsonData.isEmpty) {
      return [];
    }
    
    // Check if this page is already cached
    if (_cachedPagedSurahs.containsKey(page)) {
      return _cachedPagedSurahs[page]!;
    }

    // Calculate start and end indices
    final int startIndex = (page - 1) * pageSize;
    int endIndex = startIndex + pageSize;
    
    // Ensure end index doesn't exceed the data length
    if (endIndex > rawJsonData.length) {
      endIndex = rawJsonData.length;
    }

    // Check if requested page is valid
    if (startIndex >= rawJsonData.length) {
      return [];
    }

    // Get the subset of data for the requested page
    final List<dynamic> paginatedData = rawJsonData.sublist(startIndex, endIndex);
    
    // Process the paginated data in a separate isolate for better performance
    final List<Surah> paginatedSurahs = await compute(_processPageIsolate, paginatedData);
    
    // Cache the results for future use
    _cachedPagedSurahs[page] = paginatedSurahs;
    
    // Ensure we update the static surahs list if we're loading all data
    if (surahs.isEmpty && page == 1 && pageSize >= rawJsonData.length) {
      surahs = paginatedSurahs;
    }
    
    return paginatedSurahs;
  }
  
  // For processing paginated data in a separate isolate
  static List<Surah> _processPageIsolate(List<dynamic> data) {
    return _processAndReturnSurahs(data);
  }
  
  static int getTotalPages(int pageSize) {
    if (rawJsonData.isEmpty) {
      return 0;
    }
    
    return (rawJsonData.length / pageSize).ceil();
  }
  
  static int getTotalSurahs() {
    return rawJsonData.length;
  }
  
  static List<Surah> _processSurahsFromJson(List<dynamic> jsonData) {
    return _processAndReturnSurahs(jsonData);
  }
  
  static List<Surah> _processAndReturnSurahs(List<dynamic> jsonData) {
    // Process each JSON object into a Surah
    return jsonData.map((json) {
      final Surah surah = Surah.fromJson(json);
      
      // Assign page numbers - this is a mapping that may need to be updated
      // based on the actual PDF pages
      switch (surah.id) {
        case 1: surah.pageNumber = 1; break;
        case 2: surah.pageNumber = 2; break;
        case 3: surah.pageNumber = 50; break;
        case 4: surah.pageNumber = 77; break;
        case 5: surah.pageNumber = 106; break;
        case 6: surah.pageNumber = 128; break;
        case 7: surah.pageNumber = 151; break;
        case 8: surah.pageNumber = 177; break;
        case 9: surah.pageNumber = 187; break;
        case 10: surah.pageNumber = 208; break;
        case 11: surah.pageNumber = 221; break;
        case 12: surah.pageNumber = 235; break;
        case 13: surah.pageNumber = 249; break;
        case 14: surah.pageNumber = 255; break;
        case 15: surah.pageNumber = 262; break;
        case 16: surah.pageNumber = 267; break;
        case 17: surah.pageNumber = 282; break;
        case 18: surah.pageNumber = 293; break;
        case 19: surah.pageNumber = 305; break;
        case 20: surah.pageNumber = 312; break;
        case 21: surah.pageNumber = 322; break;
        case 22: surah.pageNumber = 332; break;
        case 23: surah.pageNumber = 342; break;
        case 24: surah.pageNumber = 350; break;
        case 25: surah.pageNumber = 359; break;
        case 26: surah.pageNumber = 367; break;
        case 27: surah.pageNumber = 377; break;
        case 28: surah.pageNumber = 385; break;
        case 29: surah.pageNumber = 396; break;
        case 30: surah.pageNumber = 404; break;
        case 31: surah.pageNumber = 411; break;
        case 32: surah.pageNumber = 415; break;
        case 33: surah.pageNumber = 418; break;
        case 34: surah.pageNumber = 428; break;
        case 35: surah.pageNumber = 434; break;
        case 36: surah.pageNumber = 440; break;
        case 37: surah.pageNumber = 446; break;
        case 38: surah.pageNumber = 453; break;
        case 39: surah.pageNumber = 458; break;
        case 40: surah.pageNumber = 467; break;
        case 41: surah.pageNumber = 477; break;
        case 42: surah.pageNumber = 483; break;
        case 43: surah.pageNumber = 489; break;
        case 44: surah.pageNumber = 496; break;
        case 45: surah.pageNumber = 499; break;
        case 46: surah.pageNumber = 502; break;
        case 47: surah.pageNumber = 507; break;
        case 48: surah.pageNumber = 511; break;
        case 49: surah.pageNumber = 515; break;
        case 50: surah.pageNumber = 518; break;
        case 51: surah.pageNumber = 520; break;
        case 52: surah.pageNumber = 523; break;
        case 53: surah.pageNumber = 526; break;
        case 54: surah.pageNumber = 528; break;
        case 55: surah.pageNumber = 531; break;
        case 56: surah.pageNumber = 534; break;
        case 57: surah.pageNumber = 537; break;
        case 58: surah.pageNumber = 542; break;
        case 59: surah.pageNumber = 545; break;
        case 60: surah.pageNumber = 549; break;
        case 61: surah.pageNumber = 551; break;
        case 62: surah.pageNumber = 553; break;
        case 63: surah.pageNumber = 554; break;
        case 64: surah.pageNumber = 556; break;
        case 65: surah.pageNumber = 558; break;
        case 66: surah.pageNumber = 560; break;
        case 67: surah.pageNumber = 562; break;
        case 68: surah.pageNumber = 564; break;
        case 69: surah.pageNumber = 566; break;
        case 70: surah.pageNumber = 568; break;
        case 71: surah.pageNumber = 570; break;
        case 72: surah.pageNumber = 572; break;
        case 73: surah.pageNumber = 574; break;
        case 74: surah.pageNumber = 575; break;
        case 75: surah.pageNumber = 577; break;
        case 76: surah.pageNumber = 578; break;
        case 77: surah.pageNumber = 580; break;
        case 78: surah.pageNumber = 582; break;
        case 79: surah.pageNumber = 583; break;
        case 80: surah.pageNumber = 585; break;
        case 81: surah.pageNumber = 586; break;
        case 82: surah.pageNumber = 587; break;
        case 83: surah.pageNumber = 587; break;
        case 84: surah.pageNumber = 589; break;
        case 85: surah.pageNumber = 590; break;
        case 86: surah.pageNumber = 591; break;
        case 87: surah.pageNumber = 591; break;
        case 88: surah.pageNumber = 592; break;
        case 89: surah.pageNumber = 593; break;
        case 90: surah.pageNumber = 594; break;
        case 91: surah.pageNumber = 595; break;
        case 92: surah.pageNumber = 595; break;
        case 93: surah.pageNumber = 596; break;
        case 94: surah.pageNumber = 596; break;
        case 95: surah.pageNumber = 597; break;
        case 96: surah.pageNumber = 597; break;
        case 97: surah.pageNumber = 598; break;
        case 98: surah.pageNumber = 598; break;
        case 99: surah.pageNumber = 599; break;
        case 100: surah.pageNumber = 599; break;
        case 101: surah.pageNumber = 600; break;
        case 102: surah.pageNumber = 600; break;
        case 103: surah.pageNumber = 601; break;
        case 104: surah.pageNumber = 601; break;
        case 105: surah.pageNumber = 601; break;
        case 106: surah.pageNumber = 602; break;
        case 107: surah.pageNumber = 602; break;
        case 108: surah.pageNumber = 602; break;
        case 109: surah.pageNumber = 603; break;
        case 110: surah.pageNumber = 603; break;
        case 111: surah.pageNumber = 603; break;
        case 112: surah.pageNumber = 604; break;
        case 113: surah.pageNumber = 604; break;
        case 114: surah.pageNumber = 604; break;
        default: surah.pageNumber = 1; // Default
      }
      
      return surah;
    }).toList();
  }

  // Directly load and process all surahs without pagination
  // This is a simpler approach that may be more reliable
  static Future<List<Surah>> loadAllSurahsDirectly() async {
    debugPrint('SurahList: Loading all surahs directly');
    
    if (!jsonLoaded) {
      await loadJsonData();
    }
    
    if (rawJsonData.isEmpty) {
      debugPrint('SurahList: Raw data is empty after loading');
      return [];
    }
    
    if (surahs.isEmpty) {
      surahs = _processAndReturnSurahs(rawJsonData);
      debugPrint('SurahList: Directly processed ${surahs.length} surahs');
    } else {
      debugPrint('SurahList: Surahs already loaded, returning ${surahs.length} surahs');
    }
    
    return surahs;
  }
} 