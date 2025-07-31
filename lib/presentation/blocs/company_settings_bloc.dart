import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_rent_car/domain/models/company_settings.dart';
import 'package:offline_rent_car/data/repositories/company_settings_repository.dart';

// Events
abstract class CompanySettingsEvent {}

class LoadCompanySettings extends CompanySettingsEvent {}

class SaveCompanySettings extends CompanySettingsEvent {
  final CompanySettings settings;
  SaveCompanySettings(this.settings);
}

class UpdateCompanySettings extends CompanySettingsEvent {
  final CompanySettings settings;
  UpdateCompanySettings(this.settings);
}

class ResetCompanySettings extends CompanySettingsEvent {}

class UpdateCompanyLogo extends CompanySettingsEvent {
  final String? logoPath;
  UpdateCompanyLogo(this.logoPath);
}

// States
abstract class CompanySettingsState {}

class CompanySettingsInitial extends CompanySettingsState {}

class CompanySettingsLoading extends CompanySettingsState {}

class CompanySettingsLoaded extends CompanySettingsState {
  final CompanySettings settings;
  CompanySettingsLoaded(this.settings);
}

class CompanySettingsSaving extends CompanySettingsState {
  final CompanySettings settings;
  CompanySettingsSaving(this.settings);
}

class CompanySettingsSaved extends CompanySettingsState {
  final CompanySettings settings;
  CompanySettingsSaved(this.settings);
}

class CompanySettingsError extends CompanySettingsState {
  final String message;
  CompanySettingsError(this.message);
}

class CompanySettingsBloc
    extends Bloc<CompanySettingsEvent, CompanySettingsState> {
  final CompanySettingsRepository _repository;

  CompanySettingsBloc(this._repository) : super(CompanySettingsInitial()) {
    on<LoadCompanySettings>(_onLoadCompanySettings);
    on<SaveCompanySettings>(_onSaveCompanySettings);
    on<UpdateCompanySettings>(_onUpdateCompanySettings);
    on<ResetCompanySettings>(_onResetCompanySettings);
    on<UpdateCompanyLogo>(_onUpdateCompanyLogo);
  }

  Future<void> _onLoadCompanySettings(
    LoadCompanySettings event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(CompanySettingsLoading());
    try {
      final settings = await _repository.getSettings();
      print('🔍 CompanySettingsBloc - Settings loaded:');
      print('   Company Name: ${settings.companyName}');
      print('   Company Address: ${settings.companyAddress}');
      print('   Company Phone: ${settings.companyPhone}');
      print('');
      emit(CompanySettingsLoaded(settings));
    } catch (e) {
      print('❌ CompanySettingsBloc - Error loading settings: $e');
      emit(CompanySettingsError('Failed to load company settings: $e'));
    }
  }

  Future<void> _onSaveCompanySettings(
    SaveCompanySettings event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(CompanySettingsSaving(event.settings));
    try {
      print('🔍 CompanySettingsBloc - Saving settings:');
      print('   Company Name: ${event.settings.companyName}');
      print('   Company Address: ${event.settings.companyAddress}');
      print('   Company Phone: ${event.settings.companyPhone}');
      print('');

      final success = await _repository.saveSettings(event.settings);
      if (success) {
        print('✅ CompanySettingsBloc - Settings saved successfully');
        emit(CompanySettingsSaved(event.settings));
      } else {
        print('❌ CompanySettingsBloc - Failed to save settings');
        emit(CompanySettingsError('Failed to save company settings'));
      }
    } catch (e) {
      print('❌ CompanySettingsBloc - Error saving settings: $e');
      emit(CompanySettingsError('Failed to save company settings: $e'));
    }
  }

  Future<void> _onUpdateCompanySettings(
    UpdateCompanySettings event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(CompanySettingsSaving(event.settings));
    try {
      final success = await _repository.updateSettings(event.settings);
      if (success) {
        emit(CompanySettingsSaved(event.settings));
      } else {
        emit(CompanySettingsError('Failed to update company settings'));
      }
    } catch (e) {
      emit(CompanySettingsError('Failed to update company settings: $e'));
    }
  }

  Future<void> _onResetCompanySettings(
    ResetCompanySettings event,
    Emitter<CompanySettingsState> emit,
  ) async {
    emit(CompanySettingsLoading());
    try {
      final success = await _repository.resetToDefaults();
      if (success) {
        final settings = await _repository.getSettings();
        emit(CompanySettingsSaved(settings));
      } else {
        emit(CompanySettingsError('Failed to reset company settings'));
      }
    } catch (e) {
      emit(CompanySettingsError('Failed to reset company settings: $e'));
    }
  }

  Future<void> _onUpdateCompanyLogo(
    UpdateCompanyLogo event,
    Emitter<CompanySettingsState> emit,
  ) async {
    if (state is CompanySettingsLoaded) {
      final currentState = state as CompanySettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        logoPath: event.logoPath,
      );

      emit(CompanySettingsSaving(updatedSettings));
      try {
        final success = await _repository.updateSettings(updatedSettings);
        if (success) {
          emit(CompanySettingsSaved(updatedSettings));
        } else {
          emit(CompanySettingsError('Failed to update company logo'));
        }
      } catch (e) {
        emit(CompanySettingsError('Failed to update company logo: $e'));
      }
    }
  }
}
