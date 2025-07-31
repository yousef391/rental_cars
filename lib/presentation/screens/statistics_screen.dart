import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_rent_car/presentation/blocs/rental_bloc.dart';
import 'package:offline_rent_car/presentation/blocs/expense_bloc.dart';
import 'package:offline_rent_car/domain/models/rental.dart';
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
            child: Column(
              children: [
                // Period Selector
                Container(
                  margin: EdgeInsets.all(16.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
                // Content
                Expanded(
                  child: BlocBuilder<RentalBloc, RentalState>(
                    builder: (context, state) {
                      if (state is RentalLoaded) {
                        return BlocBuilder<ExpenseBloc, ExpenseState>(
                          builder: (context, expenseState) {
                            if (expenseState is ExpenseLoaded) {
                              return SingleChildScrollView(
                                padding: EdgeInsets.all(16.w),
                                child: _buildDashboardContent(
                                    state.rentals, expenseState.expenses),
                              );
                            } else if (expenseState is ExpenseLoading) {
                              return _buildLoadingState();
                            } else if (expenseState is ExpenseError) {
                              return _buildErrorState(expenseState.message);
                            }
                            return _buildLoadingState();
                          },
                        );
                      } else if (state is RentalLoading) {
                        return _buildLoadingState();
                      } else if (state is RentalError) {
                        return _buildErrorState(state.message);
                      }
                      return _buildLoadingState();
                    },
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
    final activeRentals =
        rentals.where((r) => r.status == RentalStatus.active).length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Revenue',
            totalRevenue,
            Icons.trending_up,
            Colors.green,
            'DZD',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildMetricCard(
            'Total Expenses',
            totalExpenses,
            Icons.trending_down,
            Colors.red,
            'DZD',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildMetricCard(
            'Net Profit',
            netProfit,
            Icons.account_balance_wallet,
            netProfit >= 0 ? Colors.blue : Colors.orange,
            'DZD',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildMetricCard(
            'Active Rentals',
            activeRentals.toDouble(),
            Icons.directions_car,
            Colors.purple,
            '',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, double value, IconData icon, Color color, String suffix) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              const Spacer(),
              Icon(
                value >= 0 ? Icons.trending_up : Icons.trending_down,
                color: value >= 0 ? Colors.green : Colors.red,
                size: 16.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${NumberFormat('#,##0').format(value)}${suffix.isNotEmpty ? ' $suffix' : ''}',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<Rental> rentals) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Trend',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: CustomPaint(
              size: Size.infinite,
              painter: RevenueChartPainter(rentals),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChart(List<Rental> rentals) {
    final paidCount =
        rentals.where((r) => r.paymentStatus == PaymentStatus.paid).length;
    final pendingCount =
        rentals.where((r) => r.paymentStatus == PaymentStatus.pending).length;
    const overdueCount = 0; // No overdue status in enum

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Status',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem('Paid', paidCount, Colors.green),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatusItem('Pending', pendingCount, Colors.orange),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatusItem('Overdue', overdueCount, Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesBreakdown(List<Expense> expenses) {
    final categories = <String, double>{};
    for (final expense in expenses) {
      categories[expense.category.name] =
          (categories[expense.category.name] ?? 0) + expense.amount;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses Breakdown',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          ...categories.entries
              .map((entry) => _buildExpenseItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String category, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${NumberFormat('#,##0').format(amount)} DZD',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclePerformanceChart(List<Rental> rentals) {
    final vehiclePerformance = <String, int>{};
    for (final rental in rentals) {
      vehiclePerformance[rental.vehicleId] =
          (vehiclePerformance[rental.vehicleId] ?? 0) + 1;
    }

    final sortedVehicles = vehiclePerformance.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Performance',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          ...sortedVehicles
              .take(5)
              .map((entry) => _buildVehicleItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildVehicleItem(String vehicleId, int rentalCount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(Icons.directions_car, color: Colors.blue.shade600, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Vehicle $vehicleId',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$rentalCount rentals',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Rental> rentals) {
    final recentRentals = rentals.take(5).toList();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          ...recentRentals.map((rental) => _buildActivityItem(rental)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Rental rental) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: _getStatusColor(rental.status),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
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
                  'Customer ${rental.customerId} - ${rental.vehicleId}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${NumberFormat('#,##0').format(rental.totalCost)} DZD',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fuel':
        return Colors.orange;
      case 'maintenance':
        return Colors.blue;
      case 'insurance':
        return Colors.green;
      case 'repair':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.active:
        return Colors.green;
      case RentalStatus.completed:
        return Colors.blue;
    }
  }

  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'this_week':
        return Icons.view_week;
      case 'this_month':
        return Icons.calendar_view_month;
      case 'this_year':
        return Icons.calendar_today;
      case 'all_time':
        return Icons.all_inclusive;
      default:
        return Icons.calendar_today;
    }
  }

  List<Rental> _filterRentalsByPeriod(List<Rental> rentals) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'this_week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return rentals.where((r) => r.startDate.isAfter(weekStart)).toList();
      case 'this_month':
        final monthStart = DateTime(now.year, now.month, 1);
        return rentals.where((r) => r.startDate.isAfter(monthStart)).toList();
      case 'this_year':
        final yearStart = DateTime(now.year, 1, 1);
        return rentals.where((r) => r.startDate.isAfter(yearStart)).toList();
      case 'all_time':
      default:
        return rentals;
    }
  }

  List<Expense> _filterExpensesByPeriod(List<Expense> expenses) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'this_week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return expenses.where((e) => e.date.isAfter(weekStart)).toList();
      case 'this_month':
        final monthStart = DateTime(now.year, now.month, 1);
        return expenses.where((e) => e.date.isAfter(monthStart)).toList();
      case 'this_year':
        final yearStart = DateTime(now.year, 1, 1);
        return expenses.where((e) => e.date.isAfter(yearStart)).toList();
      case 'all_time':
      default:
        return expenses;
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ExpenseForm(),
    );
  }
}

class RevenueChartPainter extends CustomPainter {
  final List<Rental> rentals;

  RevenueChartPainter(this.rentals);

  @override
  void paint(Canvas canvas, Size size) {
    if (rentals.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue.shade600
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.shade600.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final maxRevenue = rentals.fold<double>(
        0, (max, rental) => math.max(max, rental.totalCost));

    if (maxRevenue == 0) return;

    final points = <Offset>[];
    for (int i = 0; i < rentals.length; i++) {
      final x = (i / (rentals.length - 1)) * size.width;
      final y =
          size.height - ((rentals[i].totalCost) / maxRevenue) * size.height;
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
        fillPath.lineTo(points[i].dx, points[i].dy);
      }

      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
