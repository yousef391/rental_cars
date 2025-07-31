import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:offline_rent_car/presentation/blocs/vehicle_bloc.dart';
import 'package:offline_rent_car/domain/models/vehicle.dart';
import 'package:offline_rent_car/presentation/widgets/vehicle_form.dart';
import 'package:offline_rent_car/presentation/widgets/maintenance_form.dart';
import 'package:offline_rent_car/data/services/image_service.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  VehicleStatus? _statusFilter;
  final ImageService _imageService = ImageService();
  final LocalizationService _localizationService = LocalizationService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<VehicleBloc>().add(SearchVehicles(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localizationService.translate('vehicles.title'),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _localizationService.translate('vehicles.subtitle'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showAddVehicleDialog(context),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 16.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _localizationService
                                    .translate('vehicles.addVehicle'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
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

              SizedBox(height: 32.h),

              // Filters Section
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: _localizationService
                                .translate('vehicles.searchHint'),
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                              size: 20.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<VehicleStatus?>(
                            value: _statusFilter,
                            hint: Text(
                              _localizationService
                                  .translate('vehicles.allStatus'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<VehicleStatus?>(
                                value: null,
                                child: Text(_localizationService
                                    .translate('vehicles.allStatus')),
                              ),
                              ...VehicleStatus.values.map((status) {
                                return DropdownMenuItem<VehicleStatus>(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8.w,
                                        height: 8.h,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(_getStatusText(status)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (VehicleStatus? value) {
                              setState(() {
                                _statusFilter = value;
                              });
                              context
                                  .read<VehicleBloc>()
                                  .add(FilterVehiclesByStatus(value));
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Vehicles List
              Expanded(
                child: BlocBuilder<VehicleBloc, VehicleState>(
                  builder: (context, state) {
                    if (state is VehicleLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade600),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _localizationService
                                  .translate('vehicles.loadingVehicles'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is VehicleLoaded) {
                      final filteredVehicles = _statusFilter != null
                          ? state.filteredVehicles
                              .where((v) => v.status == _statusFilter)
                              .toList()
                          : state.filteredVehicles;

                      if (filteredVehicles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 64.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                _localizationService
                                    .translate('vehicles.noVehiclesFound'),
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                _localizationService
                                    .translate('vehicles.tryAdjustingFilters'),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                        ),
                        itemCount: filteredVehicles.length,
                        itemBuilder: (context, index) {
                          return _buildVehicleCard(filteredVehicles[index]);
                        },
                      );
                    } else if (state is VehicleError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64.sp,
                              color: Colors.red.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _localizationService
                                  .translate('vehicles.errorLoadingVehicles'),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              state.message,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showVehicleDetails(context, vehicle),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
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
              // Header with status and car image
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _getStatusColor(vehicle.status).withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  children: [
                    // Status Icon
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: _getStatusColor(vehicle.status),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        _getStatusIcon(vehicle.status),
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.make} ${vehicle.model}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            vehicle.licensePlate,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Car Image Preview
                    if (vehicle.carImagePath != null)
                      Container(
                        width: 50.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                              color: _getStatusColor(vehicle.status)
                                  .withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: FutureBuilder<File?>(
                            future:
                                _imageService.loadImage(vehicle.carImagePath),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.file(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.directions_car,
                                        size: 16.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    );
                                  },
                                );
                              }
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.directions_car,
                                  size: 16.sp,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Vehicle details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          _localizationService.translate('vehicles.year'),
                          vehicle.year.toString()),
                      SizedBox(height: 8.h),
                      _buildDetailRow(
                          _localizationService.translate('vehicles.color'),
                          vehicle.color),
                      SizedBox(height: 8.h),
                      _buildDetailRow(
                          _localizationService.translate('vehicles.mileage'),
                          '${vehicle.currentMileage} km'),
                      SizedBox(height: 8.h),
                      _buildDetailRow(
                          _localizationService.translate('vehicles.rate'),
                          '${vehicle.dailyRentalRate} DZD/day'),
                      const Spacer(),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              _localizationService.translate('vehicles.edit'),
                              Icons.edit,
                              Colors.blue,
                              () => _showEditVehicleDialog(context, vehicle),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _buildActionButton(
                              _localizationService
                                  .translate('vehicles.maintenance'),
                              Icons.build,
                              Colors.orange,
                              () => _showMaintenanceDialog(context, vehicle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return Colors.green;
      case VehicleStatus.rented:
        return Colors.orange;
      case VehicleStatus.underMaintenance:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return Icons.check_circle;
      case VehicleStatus.rented:
        return Icons.local_shipping;
      case VehicleStatus.underMaintenance:
        return Icons.build;
    }
  }

  String _getStatusText(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return _localizationService.translate('vehicles.available');
      case VehicleStatus.rented:
        return _localizationService.translate('vehicles.rented');
      case VehicleStatus.underMaintenance:
        return _localizationService.translate('vehicles.maintenance');
    }
  }

  void _showAddVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const VehicleForm(),
    );
  }

  void _showEditVehicleDialog(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => VehicleForm(vehicle: vehicle),
    );
  }

  void _showMaintenanceDialog(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => MaintenanceForm(vehicleId: vehicle.id),
    );
  }

  void _showVehicleDetails(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${vehicle.make} ${vehicle.model}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  _localizationService.translate('vehicles.licensePlate'),
                  vehicle.licensePlate),
              _buildDetailRow(_localizationService.translate('vehicles.year'),
                  vehicle.year.toString()),
              _buildDetailRow(_localizationService.translate('vehicles.color'),
                  vehicle.color),
              _buildDetailRow(
                  _localizationService.translate('vehicles.dailyRate'),
                  '${vehicle.dailyRentalRate} DZD'),
              _buildDetailRow(
                  _localizationService.translate('vehicles.currentMileage'),
                  '${vehicle.currentMileage} km'),
              _buildDetailRow(_localizationService.translate('vehicles.status'),
                  _getStatusText(vehicle.status)),

              // Car Image Section
              if (vehicle.carImagePath != null) ...[
                SizedBox(height: 16.h),
                Text(
                  _localizationService.translate('vehicles.vehicleImage'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: Container(
                    width: 200.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: FutureBuilder<File?>(
                        future: _imageService.loadImage(vehicle.carImagePath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade600),
                              ),
                            );
                          }

                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.file(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 32.sp,
                                        color: Colors.red.shade400,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        _localizationService.translate(
                                            'vehicles.failedToLoadImage'),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }

                          return Container(
                            color: Colors.grey.shade100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 32.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  _localizationService
                                      .translate('vehicles.noCarImage'),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],

              if (vehicle.maintenanceRecords.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  _localizationService.translate('vehicles.maintenanceRecords'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                ...vehicle.maintenanceRecords.map((record) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        '${_localizationService.formatDate(record.dateOfService)}: ${record.type} - ${record.notes}',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizationService.translate('vehicles.close')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditVehicleDialog(context, vehicle);
            },
            child: Text(_localizationService.translate('vehicles.edit')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                      _localizationService.translate('vehicles.deleteVehicle')),
                  content: Text(
                    '${_localizationService.translate('vehicles.confirmDelete')} ${vehicle.make} ${vehicle.model}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                          _localizationService.translate('vehicles.cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<VehicleBloc>()
                            .add(DeleteVehicle(vehicle.id));
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(
                          _localizationService.translate('vehicles.delete')),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_localizationService.translate('vehicles.delete')),
          ),
        ],
      ),
    );
  }
}
