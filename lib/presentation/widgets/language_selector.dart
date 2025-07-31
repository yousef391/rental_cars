import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';

class LanguageSelector extends StatefulWidget {
  final VoidCallback? onLanguageChanged;

  const LanguageSelector({
    super.key,
    this.onLanguageChanged,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final LocalizationService _localizationService = LocalizationService();
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _localizationService.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return PopupMenuButton<String>(
          onSelected: _onLanguageSelected,
          itemBuilder: (context) => _buildLanguageItems(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 18.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Text(
                  _getLanguageDisplayName(_selectedLanguage),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18.sp,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildLanguageItems() {
    return LocalizationService.supportedLanguages.entries.map((entry) {
      final languageCode = entry.key;
      final languageName = entry.value;
      final isSelected = languageCode == _selectedLanguage;

      return PopupMenuItem<String>(
        value: languageCode,
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: _getLanguageFlagColor(languageCode),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _getLanguageFlag(languageCode),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? Colors.blue.shade600 : Colors.grey.shade800,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 16.sp,
                color: Colors.blue.shade600,
              ),
          ],
        ),
      );
    }).toList();
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'ar':
        return '🇸🇦';
      default:
        return '🇺🇸';
    }
  }

  Color _getLanguageFlagColor(String languageCode) {
    switch (languageCode) {
      case 'en':
        return Colors.blue.shade600;
      case 'fr':
        return Colors.blue.shade800;
      case 'ar':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  Future<void> _onLanguageSelected(String languageCode) async {
    if (languageCode != _selectedLanguage) {
      setState(() {
        _selectedLanguage = languageCode;
      });

      try {
        await _localizationService.changeLanguage(languageCode);
        widget.onLanguageChanged?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _getLanguageChangeMessage(languageCode),
                textDirection: _localizationService.textDirection,
              ),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${_localizationService.translate('messages.error')}: $e'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  String _getLanguageChangeMessage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Language changed to English';
      case 'fr':
        return 'Langue changée en Français';
      case 'ar':
        return 'تم تغيير اللغة إلى العربية';
      default:
        return 'Language changed';
    }
  }
}

class LanguageSelectorDialog extends StatefulWidget {
  const LanguageSelectorDialog({super.key});

  @override
  State<LanguageSelectorDialog> createState() => _LanguageSelectorDialogState();
}

class _LanguageSelectorDialogState extends State<LanguageSelectorDialog> {
  final LocalizationService _localizationService = LocalizationService();
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _localizationService.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.language,
                color: Colors.blue.shade600,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                _localizationService.translate('language.select_language'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                LocalizationService.supportedLanguages.entries.map((entry) {
              final languageCode = entry.key;
              final languageName = entry.value;
              final isSelected = languageCode == _selectedLanguage;

              return ListTile(
                leading: Container(
                  width: 32.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: _getLanguageFlagColor(languageCode),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getLanguageFlag(languageCode),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  languageName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Colors.blue.shade600
                        : Colors.grey.shade800,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Colors.blue.shade600,
                        size: 20.sp,
                      )
                    : null,
                onTap: () => _onLanguageSelected(languageCode),
                selected: isSelected,
                selectedTileColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _localizationService.translate('forms.cancel'),
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _applyLanguageChange();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(_localizationService.translate('forms.confirm')),
            ),
          ],
        );
      },
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'ar':
        return '🇸🇦';
      default:
        return '🇺🇸';
    }
  }

  Color _getLanguageFlagColor(String languageCode) {
    switch (languageCode) {
      case 'en':
        return Colors.blue.shade600;
      case 'fr':
        return Colors.blue.shade800;
      case 'ar':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  void _onLanguageSelected(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _applyLanguageChange() async {
    if (_selectedLanguage != _localizationService.currentLanguage) {
      try {
        await _localizationService.changeLanguage(_selectedLanguage);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _getLanguageChangeMessage(_selectedLanguage),
                textDirection: _localizationService.textDirection,
              ),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${_localizationService.translate('messages.error')}: $e'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  String _getLanguageChangeMessage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Language changed to English';
      case 'fr':
        return 'Langue changée en Français';
      case 'ar':
        return 'تم تغيير اللغة إلى العربية';
      default:
        return 'Language changed';
    }
  }
}
