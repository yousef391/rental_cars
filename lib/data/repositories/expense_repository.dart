import 'package:offline_rent_car/domain/models/expense.dart';
import 'package:offline_rent_car/data/services/storage_service.dart';

class ExpenseRepository {
  final StorageService _storageService = StorageService();

  Future<void> initialize() async {
    await _storageService.initialize();
  }

  Future<List<Expense>> getAllExpenses() async {
    final data = await _storageService.loadAllExpenses();
    return data.map((json) => Expense.fromJson(json)).toList();
  }

  Future<Expense?> getExpenseById(String id) async {
    final data = await _storageService.loadExpense(id);
    if (data != null) {
      return Expense.fromJson(data);
    }
    return null;
  }

  Future<void> saveExpense(Expense expense) async {
    await _storageService.saveExpense(expense.id, expense.toJson());
  }

  Future<void> deleteExpense(String id) async {
    await _storageService.deleteExpense(id);
  }

  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    final expenses = await getAllExpenses();
    return expenses.where((expense) => expense.category == category).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(
      DateTime startDate, DateTime endDate) async {
    final expenses = await getAllExpenses();
    return expenses
        .where((expense) =>
            expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  Future<double> getTotalExpenses() async {
    final expenses = await getAllExpenses();
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<double> getTotalExpensesByCategory(ExpenseCategory category) async {
    final expenses = await getExpensesByCategory(category);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<Map<ExpenseCategory, double>> getExpensesByCategoryMap() async {
    final expenses = await getAllExpenses();
    final Map<ExpenseCategory, double> categoryMap = {};

    for (final category in ExpenseCategory.values) {
      categoryMap[category] = 0.0;
    }

    for (final expense in expenses) {
      categoryMap[expense.category] =
          (categoryMap[expense.category] ?? 0.0) + expense.amount;
    }

    return categoryMap;
  }
}
