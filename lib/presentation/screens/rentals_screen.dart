import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/presentation/blocs/rental_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/vehicle_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/customer_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/company_settings_bloc.dart';
import 'package:offline_rent_car/domain/models/rental.dart';
import 'package:offline_rent_car/domain/models/vehicle.dart';
import 'package:offline_rent_car/domain/models/customer.dart';
import 'package:offline_rent_car/domain/models/company_settings.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';
import 'package:offline_rent_car/data/services/pdf_service.dart';
import 'package:offline_rent_car/presentation/widgets/rental_form.dart';
import 'package:offline_rent_car/presentation/widgets/payment_dialog.dart';
import 'package:offline_rent_car/presentation/widgets/rental_completion_dialog.dart';
import 'package:intl/intl.dart';

class RentalsScreen extends StatefulWidget {
  const RentalsScreen({super.key});

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  RentalStatus? _statusFilter;
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
    // Search functionality not implemented yet
    // context.read<RentalBloc>().add(SearchRentals(_searchController.text));
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
                          _localizationService.translate('rentals.title'),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _localizationService.translate('rentals.subtitle'),
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
                        colors: [
                          Colors.orange.shade600,
                          Colors.orange.shade700
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showAddRentalDialog(context),
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
                                    .translate('rentals.newRental'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
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

              // Search and Filter Section
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizationService.translate('rentals.searchAndFilter'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: _localizationService
                                  .translate('rentals.searchHint'),
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade500,
                                size: 20.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.orange.shade600, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        SizedBox(
                          width: 200.w,
                          child: DropdownButtonFormField<RentalStatus?>(
                            value: _statusFilter,
                            decoration: InputDecoration(
                              labelText: _localizationService
                                  .translate('rentals.statusFilter'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            items: [
                              DropdownMenuItem<RentalStatus?>(
                                value: null,
                                child: Text(_localizationService
                                    .translate('rentals.allStatus')),
                              ),
                              ...RentalStatus.values.map((status) {
                                return DropdownMenuItem<RentalStatus>(
                                  value: status,
                                  child: Text(_getStatusText(status)),
                                );
                              }),
                            ],
                            onChanged: (RentalStatus? value) {
                              setState(() {
                                _statusFilter = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Rentals List
              Expanded(
                child: BlocBuilder<RentalBloc, RentalState>(
                  builder: (context, state) {
                    if (state is RentalLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange.shade600),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _localizationService
                                  .translate('rentals.loadingRentals'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is RentalLoaded) {
                      final filteredRentals = _statusFilter != null
                          ? state.rentals
                              .where((r) => r.status == _statusFilter)
                              .toList()
                          : state.rentals;

                      // Sort rentals by creation date (newest first)
                      filteredRentals
                          .sort((a, b) => b.createdAt.compareTo(a.createdAt));

                      if (filteredRentals.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                _localizationService
                                    .translate('rentals.noRentalsFound'),
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                _localizationService
                                    .translate('rentals.tryAdjustingSearch'),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredRentals.length,
                        itemBuilder: (context, index) {
                          final rental = filteredRentals[index];
                          return _buildRentalCard(rental);
                        },
                      );
                    } else if (state is RentalError) {
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
                                  .translate('rentals.errorLoadingRentals'),
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
                                color: Colors.grey.shade500,
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

  Widget _buildRentalCard(Rental rental) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRentalDetails(context, rental),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
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
                // Header with status and payment info
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(rental.status).withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: _getStatusColor(rental.status),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          _getStatusIcon(rental.status),
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rental #${rental.id.substring(0, 8)}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${DateFormat('MMM dd, yyyy').format(rental.startDate)} - ${DateFormat('MMM dd, yyyy').format(rental.endDate)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color:
                                  _getPaymentStatusColor(rental.paymentStatus),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              _getPaymentStatusText(rental.paymentStatus),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${rental.totalCost.toStringAsFixed(2)} DZD',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rental details
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // Customer and Vehicle info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoSection(
                              _localizationService
                                  .translate('rentals.customer'),
                              _getCustomerName(rental.customerId),
                              Icons.person,
                              Colors.blue,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildInfoSection(
                              _localizationService.translate('rentals.vehicle'),
                              _getVehicleInfo(rental.vehicleId),
                              Icons.directions_car,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Payment and mileage info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoSection(
                              _localizationService.translate('rentals.paid'),
                              '${rental.amountPaid.toStringAsFixed(2)} DZD',
                              Icons.payment,
                              Colors.green,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildInfoSection(
                              _localizationService
                                  .translate('rentals.remaining'),
                              '${(rental.totalCost - rental.amountPaid).toStringAsFixed(2)} DZD',
                              Icons.account_balance_wallet,
                              rental.amountPaid >= rental.totalCost
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      if (rental.startMileage != null ||
                          rental.endMileage != null) ...[
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            if (rental.startMileage != null)
                              Expanded(
                                child: _buildInfoSection(
                                  _localizationService
                                      .translate('rentals.start_mileage'),
                                  '${rental.startMileage} km',
                                  Icons.speed,
                                  Colors.orange,
                                ),
                              ),
                            if (rental.startMileage != null &&
                                rental.endMileage != null)
                              SizedBox(width: 16.w),
                            if (rental.endMileage != null)
                              Expanded(
                                child: _buildInfoSection(
                                  _localizationService
                                      .translate('rentals.end_mileage'),
                                  '${rental.endMileage} km',
                                  Icons.speed,
                                  Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      ],

                      SizedBox(height: 20.h),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              _localizationService
                                  .translate('rentals.contract'),
                              Icons.description,
                              Colors.purple,
                              () => _generateContract(context, rental),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _buildActionButton(
                              _localizationService.translate('forms.edit'),
                              Icons.edit,
                              Colors.blue,
                              () => _showEditRentalDialog(context, rental),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (rental.status == RentalStatus.active) ...[
                            Expanded(
                              child: _buildActionButton(
                                _localizationService.translate('forms.payment'),
                                Icons.payment,
                                Colors.green,
                                () => _showPaymentDialog(context, rental),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildActionButton(
                                _localizationService
                                    .translate('forms.complete'),
                                Icons.check_circle,
                                Colors.orange,
                                () => _showCompletionDialog(context, rental),
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: _buildActionButton(
                                _localizationService.translate('forms.delete'),
                                Icons.delete,
                                Colors.red,
                                () => _showDeleteConfirmation(context, rental),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18.sp, color: color),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
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

  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return Colors.blue;
      case RentalStatus.completed:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return Icons.local_shipping;
      case RentalStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getStatusText(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return _localizationService.translate('rentals.active');
      case RentalStatus.completed:
        return _localizationService.translate('rentals.completed');
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

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return _localizationService.translate('rentals.pending');
      case PaymentStatus.paid:
        return _localizationService.translate('rentals.paidStatus');
    }
  }

  String _getCustomerName(String customerId) {
    final customerState = context.read<CustomerBloc>().state;
    if (customerState is CustomerLoaded) {
      final customer = customerState.customers.firstWhere(
        (c) => c.id == customerId,
        orElse: () => const Customer(
          id: '',
          fullName: 'Unknown Customer',
          phoneNumber: '',
          emailAddress: '',
          driverLicenseNumber: '',
          address: '',
        ),
      );
      return customer.fullName;
    }
    return _localizationService.translate('rentals.unknownCustomer');
  }

  String _getVehicleInfo(String vehicleId) {
    final vehicleState = context.read<VehicleBloc>().state;
    if (vehicleState is VehicleLoaded) {
      final vehicle = vehicleState.vehicles.firstWhere(
        (v) => v.id == vehicleId,
        orElse: () => const Vehicle(
          id: '',
          make: 'Unknown',
          model: 'Vehicle',
          year: 0,
          licensePlate: '',
          color: '',
          dailyRentalRate: 0,
        ),
      );
      return '${vehicle.make} ${vehicle.model}';
    }
    return _localizationService.translate('rentals.unknownVehicle');
  }

  void _showAddRentalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RentalForm(),
    );
  }

  void _showEditRentalDialog(BuildContext context, Rental rental) {
    showDialog(
      context: context,
      builder: (context) => RentalForm(rental: rental),
    );
  }

  void _showPaymentDialog(BuildContext context, Rental rental) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(rental: rental),
    );
  }

  void _showCompletionDialog(BuildContext context, Rental rental) {
    showDialog(
      context: context,
      builder: (context) => RentalCompletionDialog(rental: rental),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Rental rental) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(_localizationService.translate('rentals.deleteRentalTitle')),
        content: Text(
          '${_localizationService.translate('rentals.deleteRentalConfirmation')} #${rental.id.substring(0, 8)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizationService.translate('rentals.cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<RentalBloc>().add(DeleteRental(rental.id));
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_localizationService.translate('rentals.delete')),
          ),
        ],
      ),
    );
  }

  void _generateContract(BuildContext context, Rental rental) async {
    try {
      final vehicleState = context.read<VehicleBloc>().state;
      final customerState = context.read<CustomerBloc>().state;
      final companySettingsState = context.read<CompanySettingsBloc>().state;

      if (vehicleState is VehicleLoaded && customerState is CustomerLoaded) {
        final vehicle =
            vehicleState.vehicles.firstWhere((v) => v.id == rental.vehicleId);
        final customer = customerState.customers
            .firstWhere((c) => c.id == rental.customerId);

        // Get company settings
        CompanySettings companySettings;
        if (companySettingsState is CompanySettingsLoaded) {
          companySettings = companySettingsState.settings;
          print('🔍 Rentals Screen - Company Settings Loaded:');
          print('   Company Name: ${companySettings.companyName}');
          print('   Company Address: ${companySettings.companyAddress}');
          print('   Company Phone: ${companySettings.companyPhone}');
          print('');
        } else {
          // Use default settings if not loaded
          companySettings = CompanySettings.defaultSettings();
          print('🔍 Rentals Screen - Using Default Company Settings:');
          print('   Company Name: ${companySettings.companyName}');
          print('   Company Address: ${companySettings.companyAddress}');
          print('   Company Phone: ${companySettings.companyPhone}');
          print('');
        }

        final pdfService = PdfService();
        final doc = await pdfService.generateRentalContractPdf(
          rental: rental,
          vehicle: vehicle,
          customer: customer,
          companySettings: companySettings,
        );

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(_localizationService
                  .translate('rentals.contractGeneratedTitle')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Contract for ${customer.fullName}',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
                  Text(_localizationService
                      .translate('rentals.contractGeneratedOptions')),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    pdfService.printPdf(doc);
                  },
                  child: Text(_localizationService.translate('rentals.print')),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final path = await pdfService.savePdfToFile(
                        doc, 'rental_contract_${rental.id}');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${_localizationService.translate('rentals.contractSaved')}: $path'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(_localizationService.translate('rentals.save')),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_localizationService.translate('rentals.errorGeneratingContract')}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRentalDetails(BuildContext context, Rental rental) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '${_localizationService.translate('rentals.rentalDetailsTitle')} #${rental.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(_localizationService.translate('rentals.status'),
                  _getStatusText(rental.status)),
              _buildDetailRow(
                  _localizationService.translate('rentals.paymentStatus'),
                  _getPaymentStatusText(rental.paymentStatus)),
              _buildDetailRow(
                  _localizationService.translate('rentals.startDate'),
                  DateFormat('MMM dd, yyyy').format(rental.startDate)),
              _buildDetailRow(_localizationService.translate('rentals.endDate'),
                  DateFormat('MMM dd, yyyy').format(rental.endDate)),
              _buildDetailRow(
                  _localizationService.translate('rentals.totalCost'),
                  '${rental.totalCost.toStringAsFixed(2)} DZD'),
              _buildDetailRow(
                  _localizationService.translate('rentals.amountPaid'),
                  '${rental.amountPaid.toStringAsFixed(2)} DZD'),
              _buildDetailRow(
                  _localizationService.translate('rentals.remaining'),
                  '${(rental.totalCost - rental.amountPaid).toStringAsFixed(2)} DZD'),
              _buildDetailRow(
                  _localizationService.translate('rentals.securityDeposit'),
                  '${rental.securityDeposit.toStringAsFixed(2)} DZD'),
              if (rental.startMileage != null)
                _buildDetailRow(
                    _localizationService.translate('rentals.startMileage'),
                    '${rental.startMileage} km'),
              if (rental.endMileage != null)
                _buildDetailRow(
                    _localizationService.translate('rentals.endMileage'),
                    '${rental.endMileage} km'),
              if (rental.distanceTraveled != null)
                _buildDetailRow(
                    _localizationService.translate('rentals.distanceTraveled'),
                    '${rental.distanceTraveled} km'),
              _buildDetailRow(
                  _localizationService.translate('rentals.customer'),
                  _getCustomerName(rental.customerId)),
              _buildDetailRow(_localizationService.translate('rentals.vehicle'),
                  _getVehicleInfo(rental.vehicleId)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizationService.translate('rentals.close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
