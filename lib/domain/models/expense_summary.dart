import 'package:equatable/equatable.dart';

import 'package:expense_tracker/domain/models/expense.dart';

class ExpenseSummary extends Equatable {
  const ExpenseSummary({
    required this.total,
    required this.count,
    required this.totalsByCategory,
  });

  factory ExpenseSummary.fromExpenses(List<Expense> expenses) {
    final totals = <ExpenseCategory, int>{};
    var total = 0;
    for (final e in expenses) {
      total += e.amount;
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return ExpenseSummary(
      total: total,
      count: expenses.length,
      totalsByCategory: totals,
    );
  }

  final int total;
  final int count;
  final Map<ExpenseCategory, int> totalsByCategory;

  @override
  List<Object?> get props => [total, count, totalsByCategory];
}
