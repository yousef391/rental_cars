import 'dart:convert';
import 'package:offline_rent_car/domain/models/company_settings.dart';
import 'package:offline_rent_car/data/services/storage_service.dart';

class CompanySettingsRepository {
  final StorageService _storageService;
  static const String _fileName = 'company_settings.json';

  CompanySettingsRepository(this._storageService);

  // Load company settings
  Future<CompanySettings?> loadSettings() async {
    try {
      print(
          '🔍 CompanySettingsRepository - Loading settings from file: $_fileName');
      final data = await _storageService.readFile(_fileName);
      print('🔍 CompanySettingsRepository - Raw data: $data');
      if (data != null && data.isNotEmpty) {
        final json = jsonDecode(data);
        print('🔍 CompanySettingsRepository - Parsed JSON: $json');
        final settings = CompanySettings.fromJson(json);
        print(
            '🔍 CompanySettingsRepository - Loaded settings: ${settings.companyName}');
        return settings;
      }
      print('🔍 CompanySettingsRepository - No data found, returning null');
      return null;
    } catch (e) {
      print('❌ CompanySettingsRepository - Error loading company settings: $e');
      return null;
    }
  }

  // Save company settings
  Future<bool> saveSettings(CompanySettings settings) async {
    try {
      print(
          '🔍 CompanySettingsRepository - Saving settings to file: $_fileName');
      print(
          '🔍 CompanySettingsRepository - Settings to save: ${settings.companyName}');
      final json = jsonEncode(settings.toJson());
      print('🔍 CompanySettingsRepository - JSON to save: $json');
      await _storageService.writeFile(_fileName, json);
      print('✅ CompanySettingsRepository - Settings saved successfully');
      return true;
    } catch (e) {
      print('❌ CompanySettingsRepository - Error saving company settings: $e');
      return false;
    }
  }

  // Get default settings if none exist
  Future<CompanySettings> getSettings() async {
    final settings = await loadSettings();
    if (settings != null) {
      return settings;
    }

    // Return default settings if none exist
    final defaultSettings = CompanySettings.defaultSettings();
    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  // Update settings
  Future<bool> updateSettings(CompanySettings settings) async {
    final updatedSettings = settings.copyWith(
      updatedAt: DateTime.now(),
    );
    return await saveSettings(updatedSettings);
  }

  // Reset to default settings
  Future<bool> resetToDefaults() async {
    try {
      final defaultSettings = CompanySettings.defaultSettings();
      return await saveSettings(defaultSettings);
    } catch (e) {
      print('Error resetting company settings: $e');
      return false;
    }
  }

  // Delete settings file
  Future<bool> deleteSettings() async {
    try {
      await _storageService.deleteFile(_fileName);
      return true;
    } catch (e) {
      print('Error deleting company settings: $e');
      return false;
    }
  }
}
