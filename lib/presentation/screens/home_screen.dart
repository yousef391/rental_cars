import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/presentation/blocs/vehicle_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/rental_bloc.dart';
import 'package:offline_rent_car/presentation/screens/vehicles_screen.dart';
import 'package:offline_rent_car/presentation/screens/customers_screen.dart';
import 'package:offline_rent_car/presentation/screens/rentals_screen.dart';
import 'package:offline_rent_car/presentation/screens/calendar_screen.dart';
import 'package:offline_rent_car/presentation/screens/statistics_screen.dart';
import 'package:offline_rent_car/presentation/screens/notifications_screen.dart';
import 'package:offline_rent_car/presentation/screens/company_settings_screen.dart';
import 'package:offline_rent_car/domain/models/vehicle.dart';
import 'package:offline_rent_car/domain/models/rental.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';
import 'package:offline_rent_car/presentation/widgets/language_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final LocalizationService _localizationService = LocalizationService();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const VehiclesScreen(),
    const CustomersScreen(),
    const RentalsScreen(),
    const CalendarScreen(),
    const StatisticsScreen(),
    const NotificationsScreen(),
    const CompanySettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Scaffold(
          body: Row(
            children: [
              // Modern Sidebar Navigation
              Container(
                width: 280.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // App Header
                    Container(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              size: 32.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _localizationService.translate('app_title'),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _localizationService.translate('app_subtitle'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Language Selector
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: LanguageSelector(
                        onLanguageChanged: () {
                          setState(() {});
                        },
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Navigation Items
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: [
                          _buildNavigationItem(
                            0,
                            Icons.dashboard,
                            _localizationService
                                .translate('navigation.dashboard'),
                          ),
                          _buildNavigationItem(
                            1,
                            Icons.directions_car,
                            _localizationService
                                .translate('navigation.vehicles'),
                          ),
                          _buildNavigationItem(
                            2,
                            Icons.people,
                            _localizationService
                                .translate('navigation.customers'),
                          ),
                          _buildNavigationItem(
                            3,
                            Icons.receipt_long,
                            _localizationService
                                .translate('navigation.rentals'),
                          ),
                          _buildNavigationItem(
                            4,
                            Icons.calendar_today,
                            _localizationService
                                .translate('navigation.calendar'),
                          ),
                          _buildNavigationItem(
                            5,
                            Icons.bar_chart,
                            _localizationService
                                .translate('navigation.statistics'),
                          ),
                          _buildNavigationItem(
                            6,
                            Icons.notifications,
                            'Notifications',
                          ),
                          _buildNavigationItem(
                            7,
                            Icons.business,
                            _localizationService
                                .translate('company_settings.title'),
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.h,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  _localizationService
                                      .translate('online_status'),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.green.shade100,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _localizationService.translate('copyright'),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: Container(
                  color: Colors.grey.shade50,
                  child: Column(
                    children: [
                      // Top Header
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getCurrentScreenTitle(),
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _getCurrentScreenSubtitle(),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Screen Content
                      Expanded(
                        child: _screens[_selectedIndex],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: isSelected
                  ? Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return _localizationService.translate('dashboard.welcome_title');
      case 1:
        return _localizationService.translate('vehicles.title');
      case 2:
        return _localizationService.translate('customers.title');
      case 3:
        return _localizationService.translate('rentals.title');
      case 4:
        return _localizationService.translate('calendar.title');
      case 5:
        return _localizationService.translate('statistics.title');
      case 6:
        return 'Notifications';
      case 7:
        return _localizationService.translate('company_settings.title');
      default:
        return _localizationService.translate('dashboard.title');
    }
  }

  String _getCurrentScreenSubtitle() {
    switch (_selectedIndex) {
      case 0:
        return _localizationService.translate('dashboard.welcome_subtitle');
      case 1:
        return _localizationService.translate('vehicles.subtitle');
      case 2:
        return _localizationService.translate('customers.subtitle');
      case 3:
        return _localizationService.translate('rentals.subtitle');
      case 4:
        return _localizationService.translate('calendar.subtitle');
      case 5:
        return _localizationService.translate('statistics.title');
      case 6:
        return 'Manage notifications and alerts';
      case 7:
        return _localizationService.translate('company_settings.subtitle');
      default:
        return _localizationService.translate('dashboard.manage_business');
    }
  }
}

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService();

    return ListenableBuilder(
      listenable: localizationService,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizationService
                                .translate('dashboard.welcome_title'),
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            localizationService
                                .translate('dashboard.welcome_subtitle'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 48.sp,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Quick Overview Section
              Text(
                localizationService.translate('dashboard.quick_overview'),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 16.h),

              // Statistics Cards
              BlocBuilder<VehicleBloc, VehicleState>(
                builder: (context, vehicleState) {
                  return BlocBuilder<RentalBloc, RentalState>(
                    builder: (context, rentalState) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              Icons.directions_car,
                              localizationService
                                  .translate('dashboard.total_vehicles'),
                              _getVehicleCount(vehicleState).toString(),
                              Colors.blue,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildStatCard(
                              Icons.receipt_long,
                              localizationService
                                  .translate('dashboard.active_rentals'),
                              _getActiveRentalCount(rentalState).toString(),
                              Colors.orange,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildStatCard(
                              Icons.check_circle,
                              localizationService
                                  .translate('dashboard.available_vehicles'),
                              _getAvailableVehicleCount(vehicleState)
                                  .toString(),
                              Colors.green,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildStatCard(
                              Icons.attach_money,
                              localizationService
                                  .translate('dashboard.total_revenue'),
                              '${_getTotalRevenue(rentalState).toStringAsFixed(2)} DZD',
                              Colors.purple,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 32.h),

              // Quick Actions Section
              Text(
                localizationService.translate('dashboard.quick_actions'),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 16.h),

              // Action Cards
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      Icons.add,
                      localizationService.translate('dashboard.add_new_rental'),
                      localizationService
                          .translate('dashboard.create_new_rental'),
                      Colors.green,
                      () => _navigateToScreen(context, 3),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildActionCard(
                      Icons.directions_car,
                      localizationService.translate('dashboard.add_vehicle'),
                      localizationService
                          .translate('dashboard.register_new_vehicle'),
                      Colors.blue,
                      () => _navigateToScreen(context, 1),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildActionCard(
                      Icons.people,
                      localizationService.translate('dashboard.add_customer'),
                      localizationService
                          .translate('dashboard.register_new_customer'),
                      Colors.orange,
                      () => _navigateToScreen(context, 2),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildActionCard(
                      Icons.bar_chart,
                      localizationService
                          .translate('dashboard.view_statistics'),
                      localizationService
                          .translate('dashboard.check_business_metrics'),
                      Colors.purple,
                      () => _navigateToScreen(context, 5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      IconData icon, String title, String value, Color color) {
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
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.sp,
                ),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
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
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getVehicleCount(VehicleState state) {
    if (state is VehicleLoaded) {
      return state.vehicles.length;
    }
    return 0;
  }

  int _getActiveRentalCount(RentalState state) {
    if (state is RentalLoaded) {
      return state.rentals
          .where((rental) => rental.status == RentalStatus.active)
          .length;
    }
    return 0;
  }

  int _getAvailableVehicleCount(VehicleState state) {
    if (state is VehicleLoaded) {
      return state.vehicles
          .where((vehicle) => vehicle.status == VehicleStatus.available)
          .length;
    }
    return 0;
  }

  double _getTotalRevenue(RentalState state) {
    if (state is RentalLoaded) {
      return state.rentals.fold(0.0, (sum, rental) => sum + rental.amountPaid);
    }
    return 0.0;
  }

  void _navigateToScreen(BuildContext context, int index) {
    // This would need to be implemented to navigate to specific screens
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to screen $index'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
