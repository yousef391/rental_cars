import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:offline_rent_car/presentation/blocs/rental_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/vehicle_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/customer_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/company_settings_bloc.dart';
import 'package:offline_rent_car/domain/models/vehicle.dart';
import 'package:offline_rent_car/domain/models/customer.dart';
import 'package:offline_rent_car/domain/models/rental.dart';
import 'package:offline_rent_car/domain/models/company_settings.dart';
import 'package:offline_rent_car/data/services/pdf_service.dart';
import 'package:printing/printing.dart';

class RentalForm extends StatefulWidget {
  final Rental? rental;

  const RentalForm({super.key, this.rental});

  @override
  State<RentalForm> createState() => _RentalFormState();
}

class _RentalFormState extends State<RentalForm> {
  final _formKey = GlobalKey<FormState>();
  final _securityDepositController = TextEditingController();
  final _startMileageController = TextEditingController();
  String? _selectedVehicleId;
  String? _selectedCustomerId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  double _totalCost = 0.0;
  double _securityDeposit = 0.0;
  int? _startMileage;
  bool _generateContract = true;
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  double _initialPayment = 0.0;
  bool _useCurrentMileage = true; // Added for mileage checkbox
  DateTime _calendarMonth =
      DateTime.now(); // Added for calendar month navigation

  @override
  void initState() {
    super.initState();
    if (widget.rental != null) {
      // Edit mode - populate with existing data
      _selectedVehicleId = widget.rental!.vehicleId;
      _selectedCustomerId = widget.rental!.customerId;
      _startDate = widget.rental!.startDate;
      _endDate = widget.rental!.endDate;
      _totalCost = widget.rental!.totalCost;
      _securityDeposit = widget.rental!.securityDeposit;
      _startMileage = widget.rental!.startMileage;
      _securityDepositController.text = _securityDeposit.toString();
      if (_startMileage != null) {
        _startMileageController.text = _startMileage.toString();
      }
      _paymentStatus = widget.rental!.paymentStatus;
      _initialPayment = widget.rental!.amountPaid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.rental == null ? 'Create New Rental' : 'Edit Rental',
        style: TextStyle(fontSize: 18.sp),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<VehicleBloc, VehicleState>(
                builder: (context, vehicleState) {
                  if (vehicleState is VehicleLoaded) {
                    // Show all vehicles, but indicate their status
                    final allVehicles = vehicleState.vehicles.toList();

                    return DropdownButtonFormField<String>(
                      value: _selectedVehicleId,
                      decoration: const InputDecoration(
                        labelText: 'Select Vehicle',
                        border: OutlineInputBorder(),
                      ),
                      items: allVehicles.map((vehicle) {
                        final isAvailable =
                            vehicle.status == VehicleStatus.available;
                        final isRented = vehicle.status == VehicleStatus.rented;

                        return DropdownMenuItem(
                          value: vehicle.id,
                          child: Text(
                            '${vehicle.make} ${vehicle.model} (${vehicle.licensePlate}) - ${vehicle.dailyRentalRate} DZD/day${!isAvailable ? ' - ${isRented ? 'RENTED' : 'MAINTENANCE'}' : ''}',
                            style: TextStyle(
                              color: isAvailable ? Colors.black : Colors.grey,
                              fontWeight: isAvailable
                                  ? FontWeight.normal
                                  : FontWeight.w300,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleId = value;
                          // Reset dates when vehicle changes and ensure they're valid
                          if (value != null) {
                            final unavailableDates = _getUnavailableDates();

                            // Find a valid start date
                            DateTime validStartDate = DateTime.now();
                            while (unavailableDates.any((unavailable) =>
                                unavailable.year == validStartDate.year &&
                                unavailable.month == validStartDate.month &&
                                unavailable.day == validStartDate.day)) {
                              validStartDate =
                                  validStartDate.add(const Duration(days: 1));
                            }

                            // Find a valid end date (next day after start date)
                            DateTime validEndDate =
                                validStartDate.add(const Duration(days: 1));
                            while (unavailableDates.any((unavailable) =>
                                unavailable.year == validEndDate.year &&
                                unavailable.month == validEndDate.month &&
                                unavailable.day == validEndDate.day)) {
                              validEndDate =
                                  validEndDate.add(const Duration(days: 1));
                            }

                            _startDate = validStartDate;
                            _endDate = validEndDate;

                            // Set current mileage if checkbox is checked
                            if (_useCurrentMileage) {
                              final vehicle = vehicleState.vehicles.firstWhere(
                                (v) => v.id == value,
                              );
                              _startMileageController.text =
                                  vehicle.currentMileage.toString();
                              _startMileage = vehicle.currentMileage;
                            }
                          } else {
                            _startDate = DateTime.now();
                            _endDate =
                                DateTime.now().add(const Duration(days: 1));
                          }
                          _calculateTotalCost();
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a vehicle';
                        }

                        return null;
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),

              const SizedBox(height: 16),
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, customerState) {
                  if (customerState is CustomerLoaded) {
                    return DropdownButtonFormField<String>(
                      value: _selectedCustomerId,
                      decoration: const InputDecoration(
                        labelText: 'Select Customer',
                        border: OutlineInputBorder(),
                      ),
                      items: customerState.customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer.id,
                          child: Text(
                            '${customer.fullName} (${customer.phoneNumber})',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomerId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a customer';
                        }
                        return null;
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              // Simple Vehicle Availability Info
              if (_selectedVehicleId != null) ...[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Vehicle Availability',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            BlocBuilder<VehicleBloc, VehicleState>(
                              builder: (context, vehicleState) {
                                if (vehicleState is VehicleLoaded) {
                                  final selectedVehicle =
                                      vehicleState.vehicles.firstWhere(
                                    (v) => v.id == _selectedVehicleId,
                                  );
                                  final isAvailable = selectedVehicle.status ==
                                      VehicleStatus.available;
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green.shade50
                                          : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isAvailable
                                            ? Colors.green.shade200
                                            : Colors.orange.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      isAvailable
                                          ? 'Available'
                                          : 'Currently Rented',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: isAvailable
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        BlocBuilder<VehicleBloc, VehicleState>(
                          builder: (context, vehicleState) {
                            if (vehicleState is VehicleLoaded) {
                              final selectedVehicle =
                                  vehicleState.vehicles.firstWhere(
                                (v) => v.id == _selectedVehicleId,
                              );
                              final isAvailable = selectedVehicle.status ==
                                  VehicleStatus.available;

                              if (isAvailable) {
                                return Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green.shade600,
                                        size: 20.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Vehicle is available for rental',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  children: [
                                    Icon(Icons.warning,
                                        color: Colors.orange.shade600,
                                        size: 20.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Vehicle is currently rented',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        SizedBox(height: 16.h),
                        // Simple Calendar View
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Availability Calendar',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.chevron_left,
                                              color: Colors.blue.shade600,
                                              size: 20.sp),
                                          onPressed: () {
                                            setState(() {
                                              _calendarMonth = DateTime(
                                                _calendarMonth.year,
                                                _calendarMonth.month - 1,
                                                1,
                                              );
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                            minWidth: 32.w,
                                            minHeight: 32.h,
                                          ),
                                        ),
                                        // Today button
                                        if (_calendarMonth.year !=
                                                DateTime.now().year ||
                                            _calendarMonth.month !=
                                                DateTime.now().month)
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 4.w),
                                            child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _calendarMonth =
                                                      DateTime.now();
                                                });
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 4.h),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                'Today',
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: Colors.blue.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        Text(
                                          DateFormat('MMMM yyyy')
                                              .format(_calendarMonth),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.blue.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.chevron_right,
                                              color: Colors.blue.shade600,
                                              size: 20.sp),
                                          onPressed: () {
                                            setState(() {
                                              _calendarMonth = DateTime(
                                                _calendarMonth.year,
                                                _calendarMonth.month + 1,
                                                1,
                                              );
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                            minWidth: 32.w,
                                            minHeight: 32.h,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(12.w),
                                child: BlocBuilder<RentalBloc, RentalState>(
                                  builder: (context, rentalState) {
                                    if (rentalState is RentalLoaded) {
                                      final unavailableDates =
                                          _getUnavailableDates();
                                      return _buildSimpleCalendar(
                                          unavailableDates);
                                    }
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              // Date Selection Cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () async {
                          final unavailableDates = _getUnavailableDates();

                          // Find a valid initial date that satisfies the predicate
                          DateTime validInitialDate = _startDate;
                          final dateOnly = DateTime(_startDate.year,
                              _startDate.month, _startDate.day);
                          final isCurrentDateUnavailable = unavailableDates.any(
                              (unavailable) =>
                                  unavailable.year == dateOnly.year &&
                                  unavailable.month == dateOnly.month &&
                                  unavailable.day == dateOnly.day);

                          if (isCurrentDateUnavailable) {
                            // Find the next available date
                            DateTime nextDate = DateTime.now();
                            while (unavailableDates.any((unavailable) =>
                                unavailable.year == nextDate.year &&
                                unavailable.month == nextDate.month &&
                                unavailable.day == nextDate.day)) {
                              nextDate = nextDate.add(const Duration(days: 1));
                            }
                            validInitialDate = nextDate;
                          }

                          final date = await showDatePicker(
                            context: context,
                            initialDate: validInitialDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            selectableDayPredicate: (date) {
                              final dateOnly =
                                  DateTime(date.year, date.month, date.day);
                              return !unavailableDates.any((unavailable) =>
                                  unavailable.year == dateOnly.year &&
                                  unavailable.month == dateOnly.month &&
                                  unavailable.day == dateOnly.day);
                            },
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                              if (_endDate.isBefore(_startDate)) {
                                _endDate =
                                    _startDate.add(const Duration(days: 1));
                              }
                              _calculateTotalCost();
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.blue, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_startDate),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () async {
                          final unavailableDates = _getUnavailableDates();

                          // Find a valid initial date that satisfies the predicate
                          DateTime validInitialDate = _endDate;
                          final dateOnly = DateTime(
                              _endDate.year, _endDate.month, _endDate.day);
                          final startDateOnly = DateTime(_startDate.year,
                              _startDate.month, _startDate.day);

                          final isCurrentDateUnavailable =
                              dateOnly.isBefore(startDateOnly) ||
                                  unavailableDates.any((unavailable) =>
                                      unavailable.year == dateOnly.year &&
                                      unavailable.month == dateOnly.month &&
                                      unavailable.day == dateOnly.day);

                          if (isCurrentDateUnavailable) {
                            // Find the next available date after start date
                            DateTime nextDate =
                                _startDate.add(const Duration(days: 1));
                            while (unavailableDates.any((unavailable) =>
                                unavailable.year == nextDate.year &&
                                unavailable.month == nextDate.month &&
                                unavailable.day == nextDate.day)) {
                              nextDate = nextDate.add(const Duration(days: 1));
                            }
                            validInitialDate = nextDate;
                          }

                          final date = await showDatePicker(
                            context: context,
                            initialDate: validInitialDate,
                            firstDate: _startDate,
                            lastDate: _startDate.add(const Duration(days: 365)),
                            selectableDayPredicate: (date) {
                              final dateOnly =
                                  DateTime(date.year, date.month, date.day);
                              final startDateOnly = DateTime(_startDate.year,
                                  _startDate.month, _startDate.day);

                              if (dateOnly.isBefore(startDateOnly))
                                return false;

                              return !unavailableDates.any((unavailable) =>
                                  unavailable.year == dateOnly.year &&
                                  unavailable.month == dateOnly.month &&
                                  unavailable.day == dateOnly.day);
                            },
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                              _calculateTotalCost();
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.orange, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'End Date',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_endDate),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Show warning if there are date conflicts
              if (_selectedVehicleId != null &&
                  _hasDateConflict(_startDate, _endDate)) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning,
                          color: Colors.red.shade600, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Selected dates conflict with existing rentals for this vehicle',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              TextFormField(
                controller: _securityDepositController,
                decoration: const InputDecoration(
                  labelText: 'Security Deposit (DZD)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _securityDeposit = double.tryParse(value) ?? 0.0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter security deposit';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              // Start Mileage Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Mileage',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      CheckboxListTile(
                        title: Text(
                          'Use current vehicle mileage',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        value: _useCurrentMileage,
                        onChanged: (value) {
                          setState(() {
                            _useCurrentMileage = value ?? true;
                            if (_useCurrentMileage &&
                                _selectedVehicleId != null) {
                              // Get current vehicle mileage
                              final vehicleState =
                                  context.read<VehicleBloc>().state;
                              if (vehicleState is VehicleLoaded) {
                                final vehicle =
                                    vehicleState.vehicles.firstWhere(
                                  (v) => v.id == _selectedVehicleId,
                                );
                                _startMileageController.text =
                                    vehicle.currentMileage.toString();
                                _startMileage = vehicle.currentMileage;
                              }
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (!_useCurrentMileage) ...[
                        SizedBox(height: 12.h),
                        TextFormField(
                          controller: _startMileageController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Start Mileage (km)',
                            border: OutlineInputBorder(),
                            helperText: 'Current vehicle mileage at pickup',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _startMileage = int.tryParse(value);
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter start mileage';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid mileage';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Payment Status Selection
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Status',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<PaymentStatus>(
                        value: _paymentStatus,
                        decoration: const InputDecoration(
                          labelText: 'Initial Payment Status',
                          border: OutlineInputBorder(),
                        ),
                        items: PaymentStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getPaymentStatusText(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _paymentStatus = value!;
                            if (_paymentStatus == PaymentStatus.paid) {
                              _initialPayment = _totalCost;
                            } else {
                              _initialPayment = 0.0;
                            }
                          });
                        },
                      ),
                      if (_paymentStatus == PaymentStatus.pending) ...[
                        SizedBox(height: 16.h),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Initial Payment Amount (DZD)',
                            border: OutlineInputBorder(),
                            helperText: 'Enter the amount already paid',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _initialPayment = double.tryParse(value) ?? 0.0;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter initial payment amount';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount < 0) {
                              return 'Please enter a valid amount';
                            }
                            if (amount >= _totalCost) {
                              return 'Initial payment cannot be greater than or equal to total cost';
                            }
                            return null;
                          },
                        ),
                      ],
                      if (_paymentStatus == PaymentStatus.paid) ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade600, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Full payment received: ${_totalCost.toStringAsFixed(2)} DZD',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rental Summary',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text('Duration: ${_calculateDuration()} days'),
                      Text('Total Cost: ${_totalCost.toStringAsFixed(2)} DZD'),
                      Text(
                          'Security Deposit: ${_securityDeposit.toStringAsFixed(2)} DZD'),
                      Text(
                        'Payment Status: ${_getPaymentStatusText(_paymentStatus)}',
                        style: TextStyle(
                          color: _getPaymentStatusColor(_paymentStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_paymentStatus != PaymentStatus.pending)
                        Text(
                            'Amount Paid: ${_initialPayment.toStringAsFixed(2)} DZD'),
                      SizedBox(height: 8.h),
                      Text(
                        'Total Amount: ${(_totalCost + _securityDeposit).toStringAsFixed(2)} DZD',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (_selectedVehicleId != null) ...[
                        SizedBox(height: 8.h),
                        const Divider(),
                        Text(
                          'Vehicle Availability',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _hasDateConflict(_startDate, _endDate)
                              ? '❌ Selected dates are not available'
                              : '✅ Selected dates are available',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _hasDateConflict(_startDate, _endDate)
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              CheckboxListTile(
                title: Text(
                  'Generate Rental Contract PDF',
                  style: TextStyle(fontSize: 14.sp),
                ),
                subtitle: Text(
                  'Create a professional contract document',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                value: _generateContract,
                onChanged: (value) {
                  setState(() {
                    _generateContract = value ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
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
          child:
              Text(widget.rental == null ? 'Create Rental' : 'Update Rental'),
        ),
      ],
    );
  }

  String _calculateDuration() {
    final duration = _endDate.difference(_startDate).inDays;
    return duration.toString();
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending Payment';
      case PaymentStatus.paid:
        return 'Paid';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
    }
  }

  void _calculateTotalCost() {
    if (_selectedVehicleId != null) {
      final vehicleState = context.read<VehicleBloc>().state;
      if (vehicleState is VehicleLoaded) {
        final vehicle = vehicleState.vehicles.firstWhere(
          (v) => v.id == _selectedVehicleId,
        );
        final duration = _endDate.difference(_startDate).inDays;
        setState(() {
          _totalCost = vehicle.dailyRentalRate * duration;
        });
      }
    }
  }

  // Check if a date range conflicts with existing rentals for the selected vehicle
  bool _hasDateConflict(DateTime startDate, DateTime endDate) {
    if (_selectedVehicleId == null) return false;

    final rentalState = context.read<RentalBloc>().state;
    if (rentalState is RentalLoaded) {
      // Check for active rentals that overlap with the selected date range
      for (final rental in rentalState.rentals) {
        if (rental.vehicleId == _selectedVehicleId &&
            rental.status == RentalStatus.active) {
          // Check if the date ranges overlap
          final rentalStart = rental.startDate;
          final rentalEnd = rental.endDate;

          // Overlap occurs if:
          // 1. New start date is before rental end date AND new end date is after rental start date
          // 2. Or if editing the same rental (exclude it from conflict check)
          if (startDate.isBefore(rentalEnd) &&
              endDate.isAfter(rentalStart) &&
              (widget.rental == null || rental.id != widget.rental!.id)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // Get list of unavailable dates for the selected vehicle
  List<DateTime> _getUnavailableDates() {
    if (_selectedVehicleId == null) return [];

    final rentalState = context.read<RentalBloc>().state;
    if (rentalState is RentalLoaded) {
      List<DateTime> unavailableDates = [];

      for (final rental in rentalState.rentals) {
        if (rental.vehicleId == _selectedVehicleId &&
            rental.status == RentalStatus.active &&
            (widget.rental == null || rental.id != widget.rental!.id)) {
          // Add all dates in the rental period to unavailable dates
          DateTime currentDate = rental.startDate;
          while (currentDate.isBefore(rental.endDate) ||
              currentDate.isAtSameMomentAs(rental.endDate)) {
            unavailableDates.add(
                DateTime(currentDate.year, currentDate.month, currentDate.day));
            currentDate = currentDate.add(const Duration(days: 1));
          }
        }
      }

      return unavailableDates;
    }
    return [];
  }

  // Build a simple calendar widget
  Widget _buildSimpleCalendar(List<DateTime> unavailableDates) {
    final now = DateTime.now();
    final currentMonth = DateTime(_calendarMonth.year, _calendarMonth.month);
    final daysInMonth =
        DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    return Column(
      children: [
        // Day headers
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((day) => Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        // Calendar grid
        ...List.generate((daysInMonth + firstWeekday - 1) ~/ 7 + 1,
            (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Expanded(child: Container());
              }

              final date = DateTime(
                  _calendarMonth.year, _calendarMonth.month, dayNumber);
              final isUnavailable = unavailableDates.any((unavailable) =>
                  unavailable.year == date.year &&
                  unavailable.month == date.month &&
                  unavailable.day == date.day);
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isCurrentMonth = _calendarMonth.year == now.year &&
                  _calendarMonth.month == now.month;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.all(1.w),
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isUnavailable
                        ? Colors.red.shade100
                        : isToday && isCurrentMonth
                            ? Colors.blue.shade100
                            : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isUnavailable
                          ? Colors.red.shade300
                          : isToday && isCurrentMonth
                              ? Colors.blue.shade300
                              : Colors.grey.shade200,
                      width: isToday && isCurrentMonth ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isToday && isCurrentMonth
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isUnavailable
                            ? Colors.red.shade700
                            : isToday && isCurrentMonth
                                ? Colors.blue.shade700
                                : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
        // Legend
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'Available',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'Rented',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'Today',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicleId != null && _selectedCustomerId != null) {
        // Check for date conflicts
        if (_hasDateConflict(_startDate, _endDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Selected dates conflict with existing rentals for this vehicle. Please choose different dates.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (widget.rental == null) {
          // Create new rental
          final rental = Rental.create(
            vehicleId: _selectedVehicleId!,
            customerId: _selectedCustomerId!,
            startDate: _startDate,
            endDate: _endDate,
            totalCost: _totalCost,
            securityDeposit: _securityDeposit,
            startMileage: _startMileage,
          ).copyWith(
            paymentStatus: _paymentStatus,
            amountPaid: _initialPayment,
          );

          // Add rental to the system
          context.read<RentalBloc>().add(
                AddRental(
                  vehicleId: _selectedVehicleId!,
                  customerId: _selectedCustomerId!,
                  startDate: _startDate,
                  endDate: _endDate,
                  totalCost: _totalCost,
                  securityDeposit: _securityDeposit,
                  startMileage: _startMileage,
                  paymentStatus: _paymentStatus,
                  initialPayment: _initialPayment,
                ),
              );

          // Generate PDF contract if requested
          if (_generateContract) {
            try {
              await _generateAndShowContract(rental);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error generating contract: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } else {
          // Update existing rental
          final updatedRental = widget.rental!.copyWith(
            vehicleId: _selectedVehicleId!,
            customerId: _selectedCustomerId!,
            startDate: _startDate,
            endDate: _endDate,
            totalCost: _totalCost,
            securityDeposit: _securityDeposit,
            startMileage: _startMileage,
          );

          context.read<RentalBloc>().add(UpdateRental(updatedRental));
        }

        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _generateAndShowContract(Rental rental) async {
    // Get vehicle and customer data
    final vehicleState = context.read<VehicleBloc>().state;
    final customerState = context.read<CustomerBloc>().state;
    final companySettingsState = context.read<CompanySettingsBloc>().state;

    if (vehicleState is VehicleLoaded && customerState is CustomerLoaded) {
      final vehicle = vehicleState.vehicles.firstWhere(
        (v) => v.id == rental.vehicleId,
      );
      final customer = customerState.customers.firstWhere(
        (c) => c.id == rental.customerId,
      );

      // Get company settings
      CompanySettings companySettings;
      if (companySettingsState is CompanySettingsLoaded) {
        companySettings = companySettingsState.settings;
        print('🔍 Rental Form - Company Settings Loaded:');
        print('   Company Name: ${companySettings.companyName}');
        print('   Company Address: ${companySettings.companyAddress}');
        print('   Company Phone: ${companySettings.companyPhone}');
        print('');
      } else {
        // Use default settings if not loaded
        companySettings = CompanySettings.defaultSettings();
        print('🔍 Rental Form - Using Default Company Settings:');
        print('   Company Name: ${companySettings.companyName}');
        print('   Company Address: ${companySettings.companyAddress}');
        print('   Company Phone: ${companySettings.companyPhone}');
        print('');
      }

      // Generate PDF
      final pdfService = PdfService();
      final doc = await pdfService.generateRentalContractPdf(
        rental: rental,
        vehicle: vehicle,
        customer: customer,
        companySettings: companySettings,
      );

      // Show PDF preview
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Rental Contract Generated',
              style: TextStyle(fontSize: 18.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Contract for ${customer.fullName}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                'Vehicle: ${vehicle.make} ${vehicle.model}',
                style: TextStyle(fontSize: 14.sp),
              ),
              Text(
                'Company: ${companySettings.companyName}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      try {
                        await pdfService.printPdf(doc);
                      } catch (e) {
                        // Handle error silently
                        print('Print error: $e');
                      }
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final path = await pdfService.savePdfToFile(
                        doc,
                        'rental_contract_${rental.id}',
                      );
                      // Use a delayed call to avoid widget disposal issues
                      Future.delayed(Duration.zero, () {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Contract saved to: $path'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
