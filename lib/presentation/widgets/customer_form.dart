import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/presentation/blocs/customer_bloc.dart';
import 'package:offline_rent_car/domain/models/customer.dart';
import 'package:offline_rent_car/presentation/widgets/image_picker_widget.dart';
import 'package:offline_rent_car/data/services/image_service.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer;

  const CustomerForm({super.key, this.customer});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final ImageService _imageService = ImageService();
  final LocalizationService _localizationService = LocalizationService();

  String? _licenseCardImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _fullNameController.text = widget.customer!.fullName;
      _phoneController.text = widget.customer!.phoneNumber;
      _emailController.text = widget.customer!.emailAddress;
      _licenseController.text = widget.customer!.driverLicenseNumber;
      _addressController.text = widget.customer!.address;
      _licenseCardImagePath = widget.customer!.licenseCardImagePath;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return AlertDialog(
          title: Text(widget.customer == null
              ? _localizationService.translate('customers.addCustomer')
              : _localizationService.translate('customers.editCustomer')),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText:
                          _localizationService.translate('customers.fullName'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.requiredField');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: _localizationService
                          .translate('customers.phoneNumber'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.requiredField');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: _localizationService
                          .translate('customers.emailAddress'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.requiredField');
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return _localizationService
                            .translate('validation.invalidEmail');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _licenseController,
                    decoration: InputDecoration(
                      labelText: _localizationService
                          .translate('customers.driverLicenseNumber'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.requiredField');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText:
                          _localizationService.translate('customers.address'),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _localizationService
                            .translate('validation.requiredField');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),

                  // License Card Image Section
                  Text(
                    _localizationService
                        .translate('customers.driverLicenseCard'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: ImagePickerWidget(
                      currentImagePath: _licenseCardImagePath,
                      title: _localizationService
                          .translate('customers.licenseCard'),
                      subtitle: _localizationService
                          .translate('customers.uploadDriverLicense'),
                      icon: Icons.credit_card,
                      onImageSelected: (imagePath) {
                        setState(() {
                          _licenseCardImagePath = imagePath;
                        });
                      },
                      width: 250.w,
                      height: 200.h,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_localizationService.translate('forms.cancel')),
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.customer == null
                  ? _localizationService.translate('forms.add')
                  : _localizationService.translate('forms.update')),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final fullName = _fullNameController.text.trim();
      final phoneNumber = _phoneController.text.trim();
      final emailAddress = _emailController.text.trim();
      final driverLicenseNumber = _licenseController.text.trim();
      final address = _addressController.text.trim();

      // Save the license card image if selected
      String? savedImagePath;
      if (_licenseCardImagePath != null && _licenseCardImagePath!.isNotEmpty) {
        try {
          final fileName = 'license_${DateTime.now().millisecondsSinceEpoch}';
          final imagePath = _licenseCardImagePath!;
          savedImagePath = await _imageService.saveImage(imagePath, fileName);
        } catch (e) {
          // Handle image saving error
          print('Error saving license card image: $e');
        }
      }

      if (widget.customer == null) {
        // Add new customer
        context.read<CustomerBloc>().add(
              AddCustomer(
                fullName: fullName,
                phoneNumber: phoneNumber,
                emailAddress: emailAddress,
                driverLicenseNumber: driverLicenseNumber,
                address: address,
                licenseCardImagePath: savedImagePath,
              ),
            );
      } else {
        // Update existing customer
        final updatedCustomer = widget.customer!.copyWith(
          fullName: fullName,
          phoneNumber: phoneNumber,
          emailAddress: emailAddress,
          driverLicenseNumber: driverLicenseNumber,
          address: address,
          licenseCardImagePath:
              savedImagePath ?? widget.customer!.licenseCardImagePath,
        );
        context.read<CustomerBloc>().add(UpdateCustomer(updatedCustomer));
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
