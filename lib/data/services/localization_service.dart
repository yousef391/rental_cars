import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService extends ChangeNotifier {
  static const String _defaultLanguage = 'en';

  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, dynamic> _translations = {};
  String _currentLanguage = _defaultLanguage;
  bool _isRTL = false;

  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
  };

  // RTL languages
  static const Set<String> rtlLanguages = {'ar'};

  String get currentLanguage => _currentLanguage;
  bool get isRTL => _isRTL;
  Map<String, dynamic> get translations => _translations;

  /// Initialize the localization service
  Future<void> initialize() async {
    await _loadTranslations();
  }

  /// Load translations for current language
  Future<void> _loadTranslations() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$_currentLanguage.json',
      );
      _translations = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Fallback to English if translation file not found
      if (_currentLanguage != 'en') {
        _currentLanguage = 'en';
        await _loadTranslations();
      }
    }
  }

  /// Update RTL setting based on current language
  void _updateRTL() {
    _isRTL = rtlLanguages.contains(_currentLanguage);
  }

  /// Change language
  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      throw Exception('Unsupported language: $languageCode');
    }

    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      _updateRTL();

      // Load new translations
      await _loadTranslations();

      // Notify listeners
      notifyListeners();
    }
  }

  /// Get translation by key
  String translate(String key, {Map<String, String>? args}) {
    try {
      final keys = key.split('.');
      dynamic value = _translations;

      for (final k in keys) {
        if (value is Map<String, dynamic>) {
          value = value[k];
        } else {
          return key; // Return key if not found
        }
      }

      if (value is String) {
        String result = value;

        // Replace placeholders with arguments
        if (args != null) {
          args.forEach((placeholder, replacement) {
            result = result.replaceAll('{$placeholder}', replacement);
          });
        }

        return result;
      }

      return key; // Return key if value is not a string
    } catch (e) {
      return key; // Return key on error
    }
  }

  /// Get translation with fallback
  String translateWithFallback(String key, String fallback,
      {Map<String, String>? args}) {
    final translation = translate(key, args: args);
    return translation != key ? translation : fallback;
  }

  /// Get nested translation
  String translateNested(String baseKey, String nestedKey,
      {Map<String, String>? args}) {
    return translate('$baseKey.$nestedKey', args: args);
  }

  /// Get language name by code
  String getLanguageName(String languageCode) {
    return supportedLanguages[languageCode] ?? languageCode;
  }

  /// Get current language name
  String get currentLanguageName {
    return getLanguageName(_currentLanguage);
  }

  /// Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }

  /// Get all supported languages
  Map<String, String> get allSupportedLanguages {
    return Map.from(supportedLanguages);
  }

  /// Get RTL languages
  Set<String> get rtlLanguagesSet {
    return Set.from(rtlLanguages);
  }

  /// Check if current language is RTL
  bool get isCurrentLanguageRTL {
    return rtlLanguages.contains(_currentLanguage);
  }

  /// Get text direction for current language
  TextDirection get textDirection {
    return _isRTL ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get alignment for current language
  Alignment get textAlignment {
    return _isRTL ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// Get cross alignment for current language
  CrossAxisAlignment get crossAxisAlignment {
    return _isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  /// Get main alignment for current language
  MainAxisAlignment get mainAxisAlignment {
    return _isRTL ? MainAxisAlignment.end : MainAxisAlignment.start;
  }

  /// Format number based on current language
  String formatNumber(dynamic number) {
    if (number == null) return '';

    // For Arabic, we might want to use Arabic numerals
    if (_currentLanguage == 'ar') {
      // Convert to Arabic numerals if needed
      return number.toString();
    }

    return number.toString();
  }

  /// Format currency based on current language
  String formatCurrency(double amount, {String? currencySymbol}) {
    final symbol = currencySymbol ?? (_currentLanguage == 'ar' ? 'د.ك' : '\$');
    final formattedAmount = formatNumber(amount.toStringAsFixed(2));

    if (_currentLanguage == 'ar') {
      return '$formattedAmount $symbol';
    } else {
      return '$symbol$formattedAmount';
    }
  }

  /// Format date based on current language
  String formatDate(DateTime date) {
    // This is a simple implementation
    // In a real app, you might want to use intl package for proper localization
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    if (_currentLanguage == 'ar') {
      return '$day/$month/$year';
    } else if (_currentLanguage == 'fr') {
      return '$day/$month/$year';
    } else {
      return '$month/$day/$year';
    }
  }

  /// Get month name
  String getMonthName(int month) {
    final months = {
      'en': [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ],
      'fr': [
        'Janvier',
        'Février',
        'Mars',
        'Avril',
        'Mai',
        'Juin',
        'Juillet',
        'Août',
        'Septembre',
        'Octobre',
        'Novembre',
        'Décembre'
      ],
      'ar': [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ],
    };

    final monthNames = months[_currentLanguage] ?? months['en']!;
    return monthNames[month - 1];
  }

  /// Get day name
  String getDayName(int weekday) {
    final days = {
      'en': [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ],
      'fr': [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche'
      ],
      'ar': [
        'الاثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
        'الأحد'
      ],
    };

    final dayNames = days[_currentLanguage] ?? days['en']!;
    return dayNames[weekday - 1];
  }

  /// Reset to default language
  Future<void> resetToDefault() async {
    await changeLanguage(_defaultLanguage);
  }
}

// Extension for easy access to translations
extension LocalizationExtension on BuildContext {
  LocalizationService get localization => LocalizationService();

  String t(String key, {Map<String, String>? args}) {
    return LocalizationService().translate(key, args: args);
  }

  String tf(String key, String fallback, {Map<String, String>? args}) {
    return LocalizationService()
        .translateWithFallback(key, fallback, args: args);
  }

  String tn(String baseKey, String nestedKey, {Map<String, String>? args}) {
    return LocalizationService()
        .translateNested(baseKey, nestedKey, args: args);
  }
}
