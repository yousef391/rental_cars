import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/presentation/blocs/rental_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/vehicle_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/expense_bloc.dart';
import 'package:offline_rent_car/domain/models/rental.dart';
import 'package:offline_rent_car/domain/models/vehicle.dart';
import 'package:offline_rent_car/domain/models/expense.dart';
import 'package:offline_rent_car/presentation/widgets/expense_form.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  String _selectedPeriod = 'this_month';
  final List<Map<String, String>> _periods = [
    {'key': 'this_week', 'label': 'statistics.this_week'},
    {'key': 'this_month', 'label': 'statistics.this_month'},
    {'key': 'this_year', 'label': 'statistics.this_year'},
    {'key': 'all_time', 'label': 'statistics.all_time'}
  ];
  final LocalizationService _localizationService = LocalizationService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade800,
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.only(right: 16.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.blue.shade600,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          DropdownButton<String>(
                            value: _selectedPeriod,
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.blue.shade600,
                              size: 20.sp,
                            ),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            items: _periods.map((period) {
                              return DropdownMenuItem(
                                value: period['key'],
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getPeriodIcon(period['key']!),
                                      size: 16.sp,
                                      color: Colors.blue.shade600,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      _localizationService
                                          .translate(period['label']!),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPeriod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Dashboard Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        // Period Selection Header
                        Container(
                          margin: EdgeInsets.only(bottom: 24.h),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.blue.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1,
                            ),
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
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  _getPeriodIcon(_selectedPeriod),
                                  color: Colors.blue.shade700,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Statistics Overview',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Showing data for ${_getPeriodDisplayText(_selectedPeriod)}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        BlocBuilder<RentalBloc, RentalState>(
                          builder: (context, rentalState) {
                            if (rentalState is RentalLoaded) {
                              return BlocBuilder<ExpenseBloc, ExpenseState>(
                                builder: (context, expenseState) {
                                  if (expenseState is ExpenseLoaded) {
                                    return _buildDashboardContent(
                                      rentalState.rentals,
                                      expenseState.expenses,
                                    );
                                  } else if (expenseState is ExpenseLoading) {
                                    return _buildLoadingState();
                                  } else if (expenseState is ExpenseError) {
                                    return _buildErrorState(
                                        expenseState.message);
                                  }
                                  return _buildLoadingState();
                                },
                              );
                            } else if (rentalState is RentalLoading) {
                              return _buildLoadingState();
                            } else if (rentalState is RentalError) {
                              return _buildErrorState(rentalState.message);
                            }
                            return _buildLoadingState();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExpenseDialog(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              _localizationService.translate('statistics.add_expense'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          SizedBox(height: 16.h),
          Text(
            _localizationService.translate('statistics.loading_statistics'),
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
                .translate('statistics.error_loading_statistics'),
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(List<Rental> rentals, List<Expense> expenses) {
    final filteredRentals = _filterRentalsByPeriod(rentals);
    final filteredExpenses = _filterExpensesByPeriod(expenses);

    return Column(
      children: [
        // Key Metrics Cards
        _buildKeyMetricsRow(filteredRentals, filteredExpenses),
        SizedBox(height: 24.h),

        // Revenue Chart
        _buildRevenueChart(filteredRentals),
        SizedBox(height: 24.h),

        // Payment Status Chart
        _buildPaymentStatusChart(filteredRentals),
        SizedBox(height: 24.h),

        // Expenses Breakdown
        _buildExpensesBreakdown(filteredExpenses),
        SizedBox(height: 24.h),

        // Vehicle Performance
        _buildVehiclePerformanceChart(rentals),
        SizedBox(height: 24.h),

        // Recent Activity
        _buildRecentActivity(filteredRentals),
        SizedBox(height: 100.h), // Space for FAB
      ],
    );
  }

  Widget _buildKeyMetricsRow(List<Rental> rentals, List<Expense> expenses) {
    final totalRevenue =
        rentals.fold<double>(0, (sum, rental) => sum + rental.totalCost);
    final totalExpenses =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final netProfit = totalRevenue - totalExpenses;
    final totalPaid = rentals.fold<double>(
        0, (sum, rental) => sum + (rental.amountPaid ?? 0));

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Revenue',
            '${totalRevenue.toStringAsFixed(0)} DZD',
            Icons.trending_up,
            Colors.green,
            totalRevenue > 0
                ? '+${((totalRevenue / 1000) * 100).toStringAsFixed(1)}%'
                : '0%',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildMetricCard(
            'Net Profit',
            '${netProfit.toStringAsFixed(0)} DZD',
            Icons.account_balance_wallet,
            netProfit >= 0 ? Colors.blue : Colors.red,
            netProfit >= 0
                ? '+${((netProfit / totalRevenue) * 100).toStringAsFixed(1)}%'
                : '${((netProfit / totalRevenue) * 100).toStringAsFixed(1)}%',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildMetricCard(
            'Collections',
            '${totalPaid.toStringAsFixed(0)} DZD',
            Icons.payment,
            Colors.orange,
            '${((totalPaid / totalRevenue) * 100).toStringAsFixed(1)}%',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildMetricCard(
            'Active Rentals',
            '${rentals.where((r) => r.status == RentalStatus.active).length}',
            Icons.local_shipping,
            Colors.purple,
            '${rentals.length} total',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, String change) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<Rental> rentals) {
    // Group rentals by week for the chart
    final weeklyData = <String, double>{};
    final now = DateTime.now();

    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: (3 - i) * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekKey = DateFormat('MMM dd').format(weekStart);

      final weekRevenue = rentals
          .where((rental) =>
              rental.createdAt.isAfter(weekStart) &&
              rental.createdAt.isBefore(weekEnd))
          .fold<double>(0, (sum, rental) => sum + rental.totalCost);

      weeklyData[weekKey] = weekRevenue;
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
              Icon(Icons.trending_up,
                  color: Colors.green.shade600, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Weekly Revenue Trend',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 200.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.entries.map((entry) {
                final maxValue = weeklyData.values.reduce(math.max);
                final height =
                    maxValue > 0 ? (entry.value / maxValue) * 150.h : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40.w,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade200,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      entry.value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChart(List<Rental> rentals) {
    final paidRentals =
        rentals.where((r) => r.paymentStatus == PaymentStatus.paid).length;
    final pendingRentals =
        rentals.where((r) => r.paymentStatus == PaymentStatus.pending).length;
    final total = rentals.length;

    if (total == 0) {
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
        child: Center(
          child: Text(
            'No payment data available',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
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
              Icon(Icons.pie_chart, color: Colors.blue.shade600, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Payment Status Distribution',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 120.h,
                  child: CustomPaint(
                    painter: PieChartPainter(
                      paidPercentage: paidRentals / total,
                      pendingPercentage: pendingRentals / total,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              // Legend
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Paid', paidRentals, total, Colors.green),
                    SizedBox(height: 12.h),
                    _buildLegendItem(
                        'Pending', pendingRentals, total, Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;

    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '$value rentals (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesBreakdown(List<Expense> expenses) {
    final expenseCategories = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      expenseCategories[expense.category] =
          (expenseCategories[expense.category] ?? 0) + expense.amount;
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
              Icon(Icons.money_off, color: Colors.red.shade600, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Expenses Breakdown',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ...expenseCategories.entries.map((entry) {
            final totalExpenses =
                expenseCategories.values.reduce((a, b) => a + b);
            final percentage =
                totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0.0;

            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCategoryText(entry.key),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(0)} DZD',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value:
                        totalExpenses > 0 ? entry.value / totalExpenses : 0.0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.red.shade400),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${percentage.toStringAsFixed(1)}% of total expenses',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVehiclePerformanceChart(List<Rental> rentals) {
    final vehicleStats = <String, int>{};
    for (final rental in rentals) {
      vehicleStats[rental.vehicleId] =
          (vehicleStats[rental.vehicleId] ?? 0) + 1;
    }

    final sortedVehicles = vehicleStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
              Icon(Icons.directions_car,
                  color: Colors.purple.shade600, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Vehicle Performance',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ...sortedVehicles.take(5).map((entry) {
            final maxRentals = sortedVehicles.first.value;
            final percentage =
                maxRentals > 0 ? (entry.value / maxRentals) * 100 : 0.0;

            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vehicle ${entry.key.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        '${entry.value} rentals',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value: maxRentals > 0 ? entry.value / maxRentals : 0.0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${percentage.toStringAsFixed(1)}% of top performer',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Rental> rentals) {
    final recentRentals = rentals.take(5).toList();

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
              Icon(Icons.history, color: Colors.indigo.shade600, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ...recentRentals.map((rental) {
            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getStatusColor(rental.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getStatusIcon(rental.status),
                      color: _getStatusColor(rental.status),
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
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(rental.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${rental.totalCost.toStringAsFixed(0)} DZD',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Rental> _filterRentalsByPeriod(List<Rental> rentals) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'this_week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return rentals
            .where((rental) => rental.createdAt.isAfter(weekStart))
            .toList();
      case 'this_month':
        final monthStart = DateTime(now.year, now.month, 1);
        return rentals
            .where((rental) => rental.createdAt.isAfter(monthStart))
            .toList();
      case 'this_year':
        final yearStart = DateTime(now.year, 1, 1);
        return rentals
            .where((rental) => rental.createdAt.isAfter(yearStart))
            .toList();
      case 'all_time':
        return rentals;
      default:
        return rentals;
    }
  }

  List<Expense> _filterExpensesByPeriod(List<Expense> expenses) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'this_week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return expenses
            .where((expense) => expense.date.isAfter(weekStart))
            .toList();
      case 'this_month':
        final monthStart = DateTime(now.year, now.month, 1);
        return expenses
            .where((expense) => expense.date.isAfter(monthStart))
            .toList();
      case 'this_year':
        final yearStart = DateTime(now.year, 1, 1);
        return expenses
            .where((expense) => expense.date.isAfter(yearStart))
            .toList();
      case 'all_time':
        return expenses;
      default:
        return expenses;
    }
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

  String _getCategoryText(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fuel:
        return 'Fuel';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.registration:
        return 'Registration';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.office:
        return 'Office';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'this_week':
        return Icons.view_week;
      case 'this_month':
        return Icons.calendar_month;
      case 'this_year':
        return Icons.date_range;
      case 'all_time':
        return Icons.all_inclusive;
      default:
        return Icons.calendar_today;
    }
  }

  String _getPeriodDisplayText(String period) {
    switch (period) {
      case 'this_week':
        return 'This Week';
      case 'this_month':
        return 'This Month';
      case 'this_year':
        return 'This Year';
      case 'all_time':
        return 'All Time';
      default:
        return 'This Month';
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ExpenseForm(),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double paidPercentage;
  final double pendingPercentage;

  PieChartPainter({
    required this.paidPercentage,
    required this.pendingPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw paid slice
    final paidPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * paidPercentage,
      true,
      paidPaint,
    );

    // Draw pending slice
    final pendingPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + 2 * math.pi * paidPercentage,
      2 * math.pi * pendingPercentage,
      true,
      pendingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
