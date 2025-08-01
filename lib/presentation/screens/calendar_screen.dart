import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:rentra/presentation/blocs/vehicle_bloc.dart';
import 'package:rentra/presentation/blocs/rental_bloc.dart';
import 'package:rentra/domain/models/vehicle.dart';
import 'package:rentra/domain/models/rental.dart';
import 'package:rentra/data/services/localization_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Vehicle? _selectedVehicle;
  RentalStatus? _statusFilter;
  final LocalizationService _localizationService = LocalizationService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filters
                _buildFilters(),
                SizedBox(height: 24.h),

                // Calendar
                Expanded(
                  child: _buildCalendar(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          Text(
            _localizationService.translate('calendar.filters'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildVehicleFilter()),
              SizedBox(width: 16.w),
              Expanded(child: _buildStatusFilter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleFilter() {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is VehicleLoaded) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Vehicle?>(
                value: _selectedVehicle,
                hint: Text(
                  _localizationService.translate('calendar.allVehicles'),
                  style: TextStyle(fontSize: 14.sp),
                ),
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                        _localizationService.translate('calendar.allVehicles')),
                  ),
                  ...state.vehicles.map((vehicle) => DropdownMenuItem(
                        value: vehicle,
                        child: Text('${vehicle.make} ${vehicle.model}'),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedVehicle = value;
                  });
                },
              ),
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12.w),
              Text(
                _localizationService.translate('calendar.loadingVehicles'),
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RentalStatus?>(
          value: _statusFilter,
          hint: Text(
            _localizationService.translate('calendar.allStatus'),
            style: TextStyle(fontSize: 14.sp),
          ),
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(_localizationService.translate('calendar.allStatus')),
            ),
            ...RentalStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getRentalStatusText(status)),
                )),
          ],
          onChanged: (value) {
            setState(() {
              _statusFilter = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: 600.w, // Bigger width for 1920x1080 design
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
        children: [
          // Calendar Header
          _buildCalendarHeader(),

          // Weekday Headers
          _buildWeekdayHeaders(),

          // Calendar Grid
          SizedBox(
            height: 400.h, // Bigger height for 1920x1080 design
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
            icon: Icon(Icons.chevron_left,
                color: Colors.blue.shade600, size: 24.sp),
            padding: EdgeInsets.all(8.w),
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
            icon: Icon(Icons.chevron_right,
                color: Colors.blue.shade600, size: 24.sp),
            padding: EdgeInsets.all(8.w),
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
          return Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return GridView.builder(
      padding: EdgeInsets.all(8.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2, // Better proportions for bigger cards
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.h,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final dayOffset = index - (firstWeekday - 1);
        final day = dayOffset + 1;

        if (day < 1 || day > daysInMonth) {
          return Container(); // Empty space
        }

        final currentDate = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isToday = _isToday(currentDate);
        final isSelected =
            _selectedDay != null && _isSameDay(currentDate, _selectedDay!);
        final rentalStatus = _getRentalStatusForDay(currentDate);

        return _buildDayCard(
            currentDate, day, isToday, isSelected, rentalStatus);
      },
    );
  }

  Widget _buildDayCard(DateTime date, int day, bool isToday, bool isSelected,
      String? rentalStatus) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = date;
        });
        _showDayDetails(date);
      },
      child: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isToday ? Colors.orange.shade400 : Colors.grey.shade200,
            width: isToday ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.orange.shade700 : Colors.grey.shade800,
              ),
            ),
            if (rentalStatus != null) ...[
              SizedBox(height: 4.h),
              Container(
                width: 12.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _getRentalStatusColor(rentalStatus),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String? _getRentalStatusForDay(DateTime day) {
    try {
      final vehicleState = context.read<VehicleBloc>().state;
      final rentalState = context.read<RentalBloc>().state;

      if (vehicleState is VehicleLoaded && rentalState is RentalLoaded) {
        final vehicles = vehicleState.vehicles;
        final rentals = rentalState.rentals;

        if (vehicles.isEmpty) return null;

        final vehiclesToShow = _selectedVehicle != null
            ? [
                vehicles.firstWhere((v) => v.id == _selectedVehicle!.id,
                    orElse: () => vehicles.first)
              ]
            : vehicles;

        final rentalsToCheck = _statusFilter != null
            ? rentals.where((r) => r.status == _statusFilter).toList()
            : rentals;

        for (final vehicle in vehiclesToShow) {
          final vehicleRentals = rentalsToCheck.where((rental) {
            return rental.vehicleId == vehicle.id &&
                rental.startDate.isBefore(day.add(const Duration(days: 1))) &&
                rental.endDate.isAfter(day.subtract(const Duration(days: 1)));
          }).toList();

          if (vehicleRentals.isNotEmpty) {
            return 'rented';
          }

          final maintenanceRecords = vehicle.maintenanceRecords.where((record) {
            return record.dateOfService.year == day.year &&
                record.dateOfService.month == day.month &&
                record.dateOfService.day == day.day;
          }).toList();

          if (maintenanceRecords.isNotEmpty) {
            return 'maintenance';
          }
        }
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }

  Color _getRentalStatusColor(String status) {
    switch (status) {
      case 'rented':
        return Colors.red.shade400;
      case 'maintenance':
        return Colors.orange.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  void _showDayDetails(DateTime day) {
    final events = _getEventsForDay(day);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          DateFormat('EEEE, MMMM dd, yyyy').format(day),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400.w,
          child: events.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy,
                        size: 48.sp, color: Colors.grey.shade400),
                    SizedBox(height: 16.h),
                    Text(
                      _localizationService
                          .translate('calendar.noRentalsScheduled'),
                      style: TextStyle(
                          fontSize: 16.sp, color: Colors.grey.shade600),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      events.map((event) => _buildEventItem(event)).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizationService.translate('calendar.close')),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final events = <Map<String, dynamic>>[];

    try {
      final vehicleState = context.read<VehicleBloc>().state;
      final rentalState = context.read<RentalBloc>().state;

      if (vehicleState is VehicleLoaded && rentalState is RentalLoaded) {
        final vehicles = vehicleState.vehicles;
        final rentals = rentalState.rentals;

        if (vehicles.isEmpty) return events;

        final vehiclesToShow = _selectedVehicle != null
            ? [
                vehicles.firstWhere((v) => v.id == _selectedVehicle!.id,
                    orElse: () => vehicles.first)
              ]
            : vehicles;

        final rentalsToCheck = _statusFilter != null
            ? rentals.where((r) => r.status == _statusFilter).toList()
            : rentals;

        for (final vehicle in vehiclesToShow) {
          final vehicleRentals = rentalsToCheck.where((rental) {
            return rental.vehicleId == vehicle.id &&
                rental.startDate.isBefore(day.add(const Duration(days: 1))) &&
                rental.endDate.isAfter(day.subtract(const Duration(days: 1)));
          }).toList();

          if (vehicleRentals.isNotEmpty) {
            final rental = vehicleRentals.first;
            events.add({
              'title': '${vehicle.make} ${vehicle.model}',
              'subtitle': 'Rented',
              'color': _getRentalStatusColorForRental(rental.status),
              'rental': rental,
              'vehicle': vehicle,
            });
          } else {
            final maintenanceRecords =
                vehicle.maintenanceRecords.where((record) {
              return record.dateOfService.year == day.year &&
                  record.dateOfService.month == day.month &&
                  record.dateOfService.day == day.day;
            }).toList();

            if (maintenanceRecords.isNotEmpty) {
              events.add({
                'title': '${vehicle.make} ${vehicle.model}',
                'subtitle': 'Maintenance',
                'color': Colors.red,
                'vehicle': vehicle,
              });
            } else {
              events.add({
                'title': '${vehicle.make} ${vehicle.model}',
                'subtitle': 'Available',
                'color': Colors.green,
                'vehicle': vehicle,
              });
            }
          }
        }
      }
    } catch (e) {
      // Ignore errors
    }

    return events;
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: event['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: event['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: event['color'],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  event['subtitle'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRentalStatusColorForRental(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return Colors.orange;
      case RentalStatus.completed:
        return Colors.green;
    }
  }

  String _getRentalStatusText(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return _localizationService.translate('calendar.active');
      case RentalStatus.completed:
        return _localizationService.translate('calendar.completed');
    }
  }
}
