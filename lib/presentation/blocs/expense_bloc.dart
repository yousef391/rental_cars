import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:offline_rent_car/domain/models/expense.dart';
import 'package:offline_rent_car/data/repositories/expense_repository.dart';

// Events
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final String title;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  const AddExpense({
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  @override
  List<Object?> get props => [title, description, amount, category, date];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String id;

  const DeleteExpense(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterExpensesByCategory extends ExpenseEvent {
  final ExpenseCategory? category;

  const FilterExpensesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

// States
abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final List<Expense> filteredExpenses;
  final ExpenseCategory? categoryFilter;
  final double totalExpenses;

  const ExpenseLoaded({
    required this.expenses,
    required this.filteredExpenses,
    this.categoryFilter,
    required this.totalExpenses,
  });

  @override
  List<Object?> get props =>
      [expenses, filteredExpenses, categoryFilter, totalExpenses];

  ExpenseLoaded copyWith({
    List<Expense>? expenses,
    List<Expense>? filteredExpenses,
    ExpenseCategory? categoryFilter,
    double? totalExpenses,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      totalExpenses: totalExpenses ?? this.totalExpenses,
    );
  }
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;

  ExpenseBloc({required this.expenseRepository}) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<FilterExpensesByCategory>(_onFilterExpensesByCategory);
  }

  Future<void> _onLoadExpenses(
      LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      await expenseRepository.initialize();
      final expenses = await expenseRepository.getAllExpenses();
      final totalExpenses = await expenseRepository.getTotalExpenses();
      emit(ExpenseLoaded(
        expenses: expenses,
        filteredExpenses: expenses,
        totalExpenses: totalExpenses,
      ));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpense(
      AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      final expense = Expense.create(
        title: event.title,
        description: event.description,
        amount: event.amount,
        category: event.category,
        date: event.date,
      );

      await expenseRepository.saveExpense(expense);
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpense event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.saveExpense(event.expense);
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.deleteExpense(event.id);
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onFilterExpensesByCategory(
    FilterExpensesByCategory event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ExpenseLoaded) {
        List<Expense> filteredExpenses = currentState.expenses;

        if (event.category != null) {
          filteredExpenses =
              await expenseRepository.getExpensesByCategory(event.category!);
        }

        emit(currentState.copyWith(
          filteredExpenses: filteredExpenses,
          categoryFilter: event.category,
        ));
      }
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
