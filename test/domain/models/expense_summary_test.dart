import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/domain/models/expense_summary.dart';

void main() {
  Expense make(String id, int amount, ExpenseCategory category) => Expense(
        id: id,
        title: 'Item $id',
        amount: amount,
        category: category,
        date: DateTime(2026, 11, 18),
      );

  test('menjumlahkan total dan menghitung transaksi', () {
    final summary = ExpenseSummary.fromExpenses([
      make('1', 10000, ExpenseCategory.makanan),
      make('2', 5000, ExpenseCategory.makanan),
      make('3', 20000, ExpenseCategory.belanja),
    ]);

    expect(summary.total, 35000);
    expect(summary.count, 3);
  });

  test('mengelompokkan total per kategori', () {
    final summary = ExpenseSummary.fromExpenses([
      make('1', 10000, ExpenseCategory.makanan),
      make('2', 5000, ExpenseCategory.makanan),
      make('3', 20000, ExpenseCategory.belanja),
    ]);

    expect(summary.totalsByCategory, {
      ExpenseCategory.makanan: 15000,
      ExpenseCategory.belanja: 20000,
    });
  });

  test('daftar kosong menghasilkan total 0', () {
    final summary = ExpenseSummary.fromExpenses(const []);

    expect(summary.total, 0);
    expect(summary.totalsByCategory, isEmpty);
  });
}
