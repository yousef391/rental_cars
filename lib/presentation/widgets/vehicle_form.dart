import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/presentation/blocs/vehicle_bloc.dart';
import 'package:offline_rent_car/domain/models/vehicle.dart';
import 'package:offline_rent_car/presentation/widgets/image_picker_widget.dart';
import 'package:offline_rent_car/data/services/image_service.dart';

class VehicleForm extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleForm({super.key, this.vehicle});

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _currentMileageController = TextEditingController();
  final ImageService _imageService = ImageService();
  VehicleStatus _status = VehicleStatus.available;

  String? _carImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _makeController.text = widget.vehicle!.make;
      _modelController.text = widget.vehicle!.model;
      _yearController.text = widget.vehicle!.year.toString();
      _licensePlateController.text = widget.vehicle!.licensePlate;
      _colorController.text = widget.vehicle!.color;
      _dailyRateController.text = widget.vehicle!.dailyRentalRate.toString();
      _currentMileageController.text =
          widget.vehicle!.currentMileage.toString();
      _status = widget.vehicle!.status;
      _carImagePath = widget.vehicle!.carImagePath;
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _dailyRateController.dispose();
    _currentMileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Make',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the make';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the year';
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the license plate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the color';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dailyRateController,
                decoration: const InputDecoration(
                  labelText: 'Daily Rental Rate (DZD)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the daily rental rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate <= 0) {
                    return 'Please enter a valid rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentMileageController,
                decoration: const InputDecoration(
                  labelText: 'Current Mileage (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the current mileage';
                  }
                  final mileage = int.tryParse(value);
                  if (mileage == null || mileage < 0) {
                    return 'Please enter a valid mileage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VehicleStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: VehicleStatus.values.map((status) {
                  return DropdownMenuItem<VehicleStatus>(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              SizedBox(height: 24.h),

              // Car Image Section
              Text(
                'Vehicle Image',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: ImagePickerWidget(
                  currentImagePath: _carImagePath,
                  title: 'Vehicle Photo',
                  subtitle: 'Upload car image',
                  icon: Icons.directions_car,
                  onImageSelected: (imagePath) {
                    setState(() {
                      _carImagePath = imagePath;
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(widget.vehicle == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final make = _makeController.text;
      final model = _modelController.text;
      final year = int.parse(_yearController.text);
      final licensePlate = _licensePlateController.text;
      final color = _colorController.text;
      final dailyRate = double.parse(_dailyRateController.text);
      final currentMileage = int.parse(_currentMileageController.text);

      // Save the car image if selected
      String? savedImagePath;
      if (_carImagePath != null) {
        final fileName = 'car_${DateTime.now().millisecondsSinceEpoch}';
        savedImagePath =
            await _imageService.saveImage(_carImagePath!, fileName);
      }

      if (widget.vehicle == null) {
        // Add new vehicle
        context.read<VehicleBloc>().add(
              AddVehicle(
                make: make,
                model: model,
                year: year,
                licensePlate: licensePlate,
                color: color,
                dailyRentalRate: dailyRate,
                currentMileage: currentMileage,
                carImagePath: savedImagePath,
              ),
            );
      } else {
        // Update existing vehicle
        final updatedVehicle = widget.vehicle!.copyWith(
          make: make,
          model: model,
          year: year,
          licensePlate: licensePlate,
          color: color,
          dailyRentalRate: dailyRate,
          currentMileage: currentMileage,
          status: _status,
          carImagePath: savedImagePath ?? widget.vehicle!.carImagePath,
        );
        context.read<VehicleBloc>().add(UpdateVehicle(updatedVehicle));
      }

      Navigator.of(context).pop();
    }
  }
}
