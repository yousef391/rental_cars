import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  maintenance,
  fuel,
  insurance,
  registration,
  utilities,
  office,
  marketing,
  other
}

class Expense extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  factory Expense.create({
    required String title,
    required String description,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
  }) {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      amount: amount,
      category: category,
      date: date,
      createdAt: DateTime.now(),
    );
  }

  Expense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        amount,
        category,
        date,
        createdAt,
      ];
} 