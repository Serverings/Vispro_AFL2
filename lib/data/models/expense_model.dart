import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/domain/models/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.category,
    required super.date,
    super.note = '',
  });

  factory ExpenseModel.fromExpense(Expense entity) => ExpenseModel(
        id: entity.id,
        title: entity.title,
        amount: entity.amount,
        category: entity.category,
        date: entity.date,
        note: entity.note,
      );

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    try {
      return ExpenseModel(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: map['amount'] as int,
        category: ExpenseCategory.values.byName(map['category'] as String),
        date: DateTime.parse(map['date'] as String),
        note: (map['note'] as String?) ?? '',
      );
    } catch (_) {
      throw const MalformedDataException();
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category.name,
        'date': date.toIso8601String(),
        'note': note,
      };
}
