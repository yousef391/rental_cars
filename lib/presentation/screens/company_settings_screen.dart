import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentra/data/services/localization_service.dart';
import 'package:rentra/data/services/image_service.dart';
import 'package:rentra/domain/models/company_settings.dart';
import 'package:rentra/presentation/blocs/company_settings_bloc.dart';
import 'package:rentra/presentation/widgets/image_picker_widget.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _localizationService = LocalizationService();
  final _imageService = ImageService();

  // Controllers
  late TextEditingController _companyNameController;
  late TextEditingController _companyAddressController;
  late TextEditingController _companyPhoneController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    context.read<CompanySettingsBloc>().add(LoadCompanySettings());
  }

  void _initializeControllers() {
    _companyNameController = TextEditingController();
    _companyAddressController = TextEditingController();
    _companyPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    super.dispose();
  }

  void _populateControllers(CompanySettings settings) {
    _companyNameController.text = settings.companyName;
    _companyAddressController.text = settings.companyAddress;
    _companyPhoneController.text = settings.companyPhone;
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = CompanySettings(
        id: 'default',
        companyName: _companyNameController.text.trim(),
        companyAddress: _companyAddressController.text.trim(),
        companyPhone: _companyPhoneController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('🔍 CompanySettingsScreen - Saving settings:');
      print('   Company Name: ${settings.companyName}');
      print('   Company Address: ${settings.companyAddress}');
      print('   Company Phone: ${settings.companyPhone}');
      print('');

      context.read<CompanySettingsBloc>().add(SaveCompanySettings(settings));
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_localizationService
            .translate('company_settings.reset_to_defaults')),
        content: Text(
            _localizationService.translate('company_settings.confirm_reset')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_localizationService.translate('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_localizationService.translate('common.confirm')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<CompanySettingsBloc>().add(ResetCompanySettings());
    }
  }

  Future<void> _uploadLogo() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final savedPath =
            await _imageService.saveImage(image.path, 'company_logo');
        if (savedPath != null) {
          context.read<CompanySettingsBloc>().add(UpdateCompanyLogo(savedPath));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _localizationService.translate('company_settings.logo_error')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeLogo() async {
    context.read<CompanySettingsBloc>().add(UpdateCompanyLogo(null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocListener<CompanySettingsBloc, CompanySettingsState>(
        listener: (context, state) {
          if (state is CompanySettingsLoaded) {
            _populateControllers(state.settings);
          } else if (state is CompanySettingsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_localizationService
                    .translate('company_settings.settings_saved')),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CompanySettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<CompanySettingsBloc, CompanySettingsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 1.sh - 100.h, // Account for header
                ),
                child: state is CompanySettingsLoading
                    ? _buildLoadingState()
                    : _buildEnhancedSettingsForm(state),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedSettingsForm(CompanySettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Logo Section
        _buildEnhancedLogoSection(state),

        SizedBox(height: 24.h),

        // Company Information Form
        _buildEnhancedCompanyInfoSection(),

        SizedBox(height: 32.h),

        // Action Buttons
        _buildEnhancedActionButtons(state),

        // Add bottom padding for better spacing
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildEnhancedLogoSection(CompanySettingsState state) {
    String? logoPath;
    if (state is CompanySettingsLoaded) {
      logoPath = state.settings.logoPath;
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.image,
                  color: Colors.orange.shade600,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                _localizationService.translate('company_settings.company_logo'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Logo Display
          Center(
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: logoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.file(
                        File(logoPath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildLogoPlaceholder();
                        },
                      ),
                    )
                  : _buildLogoPlaceholder(),
            ),
          ),

          SizedBox(height: 20.h),

          // Logo Actions - Responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600.w;

              if (isSmallScreen) {
                // Stack buttons vertically on small screens
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploadLogo,
                        icon: Icon(Icons.upload, size: 18.sp),
                        label: Text(_localizationService
                            .translate('company_settings.upload_logo')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    if (logoPath != null) ...[
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _removeLogo,
                          icon: Icon(Icons.delete, size: 18.sp),
                          label: Text(_localizationService
                              .translate('company_settings.remove_logo')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              } else {
                // Side by side on larger screens
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _uploadLogo,
                      icon: Icon(Icons.upload, size: 18.sp),
                      label: const Text('Upload Logo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    if (logoPath != null) ...[
                      SizedBox(width: 12.w),
                      OutlinedButton.icon(
                        onPressed: _removeLogo,
                        icon: Icon(Icons.delete, size: 18.sp),
                        label: Text(_localizationService
                            .translate('company_settings.remove_logo')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.business,
          size: 40.sp,
          color: Colors.grey.shade400,
        ),
        SizedBox(height: 8.h),
        Text(
          _localizationService.translate('company_settings.no_logo'),
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCompanyInfoSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.info,
                    color: Colors.green.shade600,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  _localizationService
                      .translate('company_settings.company_details'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Company Name
            _buildEnhancedTextField(
              controller: _companyNameController,
              label: _localizationService
                  .translate('company_settings.company_name'),
              hint: _localizationService
                  .translate('company_settings.company_name_hint'),
              icon: Icons.business,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return _localizationService
                      .translate('validation.required_field');
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Company Address
            _buildEnhancedTextField(
              controller: _companyAddressController,
              label: _localizationService
                  .translate('company_settings.company_address'),
              hint: _localizationService
                  .translate('company_settings.company_address_hint'),
              icon: Icons.location_on,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return _localizationService
                      .translate('validation.required_field');
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Company Phone
            _buildEnhancedTextField(
              controller: _companyPhoneController,
              label: _localizationService
                  .translate('company_settings.company_phone'),
              hint: _localizationService
                  .translate('company_settings.company_phone_hint'),
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return _localizationService
                      .translate('validation.required_field');
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.blue.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedActionButtons(CompanySettingsState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600.w;

        if (isSmallScreen) {
          // Stack buttons vertically on small screens
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      state is CompanySettingsSaving ? null : _saveSettings,
                  icon: state is CompanySettingsSaving
                      ? SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.save, size: 20.sp),
                  label: Text(
                    state is CompanySettingsSaving
                        ? _localizationService.translate('common.saving')
                        : _localizationService
                            .translate('company_settings.save_settings'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _resetToDefaults,
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: Text(_localizationService
                      .translate('company_settings.reset_to_defaults')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade600,
                    side: BorderSide(color: Colors.orange.shade300),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testCompanySettings,
                  icon: Icon(Icons.bug_report, size: 20.sp),
                  label: Text(_localizationService
                      .translate('company_settings.test_company_settings')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple.shade600,
                    side: BorderSide(color: Colors.purple.shade300),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Side by side on larger screens
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          state is CompanySettingsSaving ? null : _saveSettings,
                      icon: state is CompanySettingsSaving
                          ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.save, size: 20.sp),
                      label: Text(
                        state is CompanySettingsSaving
                            ? 'Saving...'
                            : 'Save Settings',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  OutlinedButton.icon(
                    onPressed: _resetToDefaults,
                    icon: Icon(Icons.refresh, size: 20.sp),
                    label: const Text('Reset to Defaults'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade600,
                      side: BorderSide(color: Colors.orange.shade300),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testCompanySettings,
                  icon: Icon(Icons.bug_report, size: 20.sp),
                  label: Text(_localizationService
                      .translate('company_settings.test_company_settings')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple.shade600,
                    side: BorderSide(color: Colors.purple.shade300),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _testCompanySettings() async {
    print('🧪 Testing Company Settings...');

    // Test 1: Save test settings
    final testSettings = CompanySettings(
      id: 'test',
      companyName: 'Test Company Name',
      companyAddress: 'Test Company Address',
      companyPhone: 'Test Company Phone',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('🧪 Test 1: Saving test settings...');
    context.read<CompanySettingsBloc>().add(SaveCompanySettings(testSettings));

    // Wait a bit and then reload
    await Future.delayed(const Duration(seconds: 2));

    print('🧪 Test 2: Reloading settings...');
    context.read<CompanySettingsBloc>().add(LoadCompanySettings());
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            strokeWidth: 3.w,
          ),
          SizedBox(height: 16.h),
          Text(
            _localizationService.translate('company_settings.loading_settings'),
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
