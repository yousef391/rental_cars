import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:offline_rent_car/presentation/blocs/customer_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/rental_bloc.dart';
import 'package:offline_rent_car/domain/models/customer.dart';
import 'package:offline_rent_car/domain/models/rental.dart';
import 'package:offline_rent_car/presentation/widgets/customer_form.dart';
import 'package:offline_rent_car/data/services/image_service.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';

// Customer Loyalty System
enum LoyaltyLevel { none, bronze, silver, gold }

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImageService _imageService = ImageService();
  final LocalizationService _localizationService = LocalizationService();
  LoyaltyLevel? _selectedLoyaltyLevel;

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
    context.read<CustomerBloc>().add(SearchCustomers(_searchController.text));
  }

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
                // Add Customer Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildAddButton(),
                  ],
                ),
                SizedBox(height: 24.h),

                // Search Section
                _buildSearchSection(),
                SizedBox(height: 16.h),

                // Loyalty Filter Section
                _buildLoyaltyFilterSection(),
                SizedBox(height: 24.h),

                // Customers List
                Expanded(
                  child: _buildCustomersList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddCustomerDialog(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _localizationService.translate('customers.addCustomer'),
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
    );
  }

  Widget _buildSearchSection() {
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
          Row(
            children: [
              Icon(
                Icons.search,
                color: Colors.green.shade600,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _localizationService.translate('customers.searchAndFilter'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _localizationService.translate('customers.searchHint'),
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
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.green.shade600, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyFilterSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: Colors.amber.shade600,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'Loyalty Status:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLoyaltyFilterChip('All', null),
                  SizedBox(width: 8.w),
                  _buildLoyaltyFilterChip(
                      'Bronze (5+ rentals)', LoyaltyLevel.bronze),
                  SizedBox(width: 8.w),
                  _buildLoyaltyFilterChip(
                      'Gold (15+ rentals)', LoyaltyLevel.gold),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyFilterChip(String label, LoyaltyLevel? level) {
    final isSelected = _selectedLoyaltyLevel == level;
    final color = level == null ? Colors.grey : _getLoyaltyColor(level);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : color,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedLoyaltyLevel = selected ? level : null;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? color : Colors.grey.shade300,
        width: 1,
      ),
    );
  }

  Widget _buildCustomersList() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, customerState) {
        if (customerState is CustomerLoading) {
          return _buildLoadingState();
        } else if (customerState is CustomerLoaded) {
          if (customerState.filteredCustomers.isEmpty) {
            return _buildEmptyState();
          }
          return BlocBuilder<RentalBloc, RentalState>(
            builder: (context, rentalState) {
              if (rentalState is RentalLoaded) {
                final filteredCustomers = _filterCustomersByLoyalty(
                    customerState.filteredCustomers, rentalState.rentals);
                return _buildCustomersGrid(
                    filteredCustomers, rentalState.rentals);
              }
              final filteredCustomers = _filterCustomersByLoyalty(
                  customerState.filteredCustomers, []);
              return _buildCustomersGrid(filteredCustomers, []);
            },
          );
        } else if (customerState is CustomerError) {
          return _buildErrorState(customerState.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
          ),
          SizedBox(height: 16.h),
          Text(
            _localizationService.translate('customers.loadingCustomers'),
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _localizationService.translate('customers.noCustomersFound'),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _localizationService.translate('customers.tryAdjustingSearch'),
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _localizationService.translate('customers.errorLoadingCustomers'),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersGrid(List<Customer> customers, List<Rental> rentals) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.2,
      ),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(customer, rentals);
      },
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildCustomerCard(Customer customer, List<Rental> rentals) {
    final rentalCount = _getCustomerRentalCount(customer.id, rentals);
    final loyaltyLevel = _getLoyaltyLevel(rentalCount);

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCustomerDetails(context, customer),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar and actions
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  customer.fullName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Loyalty Star
                              if (loyaltyLevel != LoyaltyLevel.none) ...[
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.star,
                                  color: _getLoyaltyColor(loyaltyLevel),
                                  size: 20.sp,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            customer.phoneNumber,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          // Loyalty Status
                          if (loyaltyLevel != LoyaltyLevel.none) ...[
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: _getLoyaltyColor(loyaltyLevel)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: _getLoyaltyColor(loyaltyLevel)
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$rentalCount rentals - ${_getLoyaltyText(loyaltyLevel)}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: _getLoyaltyColor(loyaltyLevel),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCustomerDialog(context, customer);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, customer);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(
                                  _localizationService.translate('forms.edit')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete,
                                  color: Colors.red, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(_localizationService
                                  .translate('forms.delete')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Customer details
                _buildDetailItem(
                  Icons.email,
                  _localizationService.translate('customers.email'),
                  customer.emailAddress,
                ),
                SizedBox(height: 8.h),
                _buildDetailItem(
                  Icons.credit_card,
                  _localizationService.translate('customers.license'),
                  customer.driverLicenseNumber,
                ),
                SizedBox(height: 8.h),
                _buildDetailItem(
                  Icons.location_on,
                  _localizationService.translate('customers.address'),
                  customer.address,
                ),

                const Spacer(),

                // License image preview
                if (customer.licenseCardImagePath != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    height: 60.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: FutureBuilder<File?>(
                        future: _imageService
                            .loadImage(customer.licenseCardImagePath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.file(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              },
                            );
                          }
                          return _buildImagePlaceholder();
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.credit_card,
          size: 24.sp,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CustomerForm(),
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => CustomerForm(customer: customer),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            _localizationService.translate('customers.deleteCustomerTitle')),
        content: Text(
          '${_localizationService.translate('customers.deleteCustomerConfirmation')} ${customer.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_localizationService.translate('customers.cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<CustomerBloc>().add(DeleteCustomer(customer.id));
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_localizationService.translate('forms.delete')),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<RentalBloc, RentalState>(
        builder: (context, rentalState) {
          final rentals =
              rentalState is RentalLoaded ? rentalState.rentals : <Rental>[];
          final rentalCount = _getCustomerRentalCount(customer.id, rentals);
          final loyaltyLevel = _getLoyaltyLevel(rentalCount);

          return AlertDialog(
            title: Row(
              children: [
                Expanded(child: Text(customer.fullName)),
                if (loyaltyLevel != LoyaltyLevel.none) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.star,
                    color: _getLoyaltyColor(loyaltyLevel),
                    size: 24.sp,
                  ),
                ],
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loyalty Information
                  if (loyaltyLevel != LoyaltyLevel.none) ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: _getLoyaltyColor(loyaltyLevel).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              _getLoyaltyColor(loyaltyLevel).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: _getLoyaltyColor(loyaltyLevel),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getLoyaltyText(loyaltyLevel),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _getLoyaltyColor(loyaltyLevel),
                                  ),
                                ),
                                Text(
                                  '$rentalCount total rentals',
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
                    ),
                    SizedBox(height: 16.h),
                  ],

                  _buildDetailRow(
                      _localizationService.translate('customers.phone'),
                      customer.phoneNumber),
                  _buildDetailRow(
                      _localizationService.translate('customers.email'),
                      customer.emailAddress),
                  _buildDetailRow(
                      _localizationService.translate('customers.licenseNumber'),
                      customer.driverLicenseNumber),
                  _buildDetailRow(
                      _localizationService.translate('customers.address'),
                      customer.address),

                  // License Card Image Section
                  if (customer.licenseCardImagePath != null) ...[
                    SizedBox(height: 16.h),
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
                            future: _imageService
                                .loadImage(customer.licenseCardImagePath),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green.shade600),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 32.sp,
                                            color: Colors.red.shade400,
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            _localizationService.translate(
                                                'customers.failedToLoadImage'),
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
                                      Icons.credit_card,
                                      size: 32.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      _localizationService.translate(
                                          'customers.noLicenseImage'),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_localizationService.translate('customers.close')),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
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
      ),
    );
  }

  // Customer Loyalty System Methods
  int _getCustomerRentalCount(String customerId, List<Rental> rentals) {
    return rentals.where((rental) => rental.customerId == customerId).length;
  }

  LoyaltyLevel _getLoyaltyLevel(int rentalCount) {
    if (rentalCount >= 15) {
      return LoyaltyLevel.gold;
    } else if (rentalCount >= 5) {
      return LoyaltyLevel.bronze;
    }
    return LoyaltyLevel.none;
  }

  Color _getLoyaltyColor(LoyaltyLevel level) {
    switch (level) {
      case LoyaltyLevel.bronze:
        return Colors.blue;
      case LoyaltyLevel.silver:
        return Colors.grey.shade600;
      case LoyaltyLevel.gold:
        return Colors.amber.shade600;
      case LoyaltyLevel.none:
        return Colors.transparent;
    }
  }

  String _getLoyaltyText(LoyaltyLevel level) {
    switch (level) {
      case LoyaltyLevel.bronze:
        return 'Bronze Member';
      case LoyaltyLevel.silver:
        return 'Silver Member';
      case LoyaltyLevel.gold:
        return 'Gold Member';
      case LoyaltyLevel.none:
        return '';
    }
  }

  List<Customer> _filterCustomersByLoyalty(
      List<Customer> customers, List<Rental> rentals) {
    if (_selectedLoyaltyLevel == null) {
      return customers;
    }

    return customers.where((customer) {
      final rentalCount = _getCustomerRentalCount(customer.id, rentals);
      final customerLoyaltyLevel = _getLoyaltyLevel(rentalCount);
      return customerLoyaltyLevel == _selectedLoyaltyLevel;
    }).toList();
  }

  Widget _buildLoyaltySummary(List<Rental> rentals) {
    final allCustomers = context.read<CustomerBloc>().state is CustomerLoaded
        ? (context.read<CustomerBloc>().state as CustomerLoaded).customers
        : <Customer>[];

    int bronzeCount = 0;
    int goldCount = 0;

    for (final customer in allCustomers) {
      final rentalCount = _getCustomerRentalCount(customer.id, rentals);
      final loyaltyLevel = _getLoyaltyLevel(rentalCount);
      if (loyaltyLevel == LoyaltyLevel.bronze) bronzeCount++;
      if (loyaltyLevel == LoyaltyLevel.gold) goldCount++;
    }

    return Row(
      children: [
        if (bronzeCount > 0) ...[
          Row(
            children: [
              Icon(Icons.star, color: Colors.blue, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                '$bronzeCount Bronze',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
        ],
        if (goldCount > 0) ...[
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade600, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                '$goldCount Gold',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.amber.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
