import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  makanan('Makanan'),
  transportasi('Transportasi'),
  belanja('Belanja'),
  tagihan('Tagihan'),
  hiburan('Hiburan'),
  lainnya('Lainnya');

  const ExpenseCategory(this.label);

  final String label;
}

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
  });

  final String id;
  final String title;
  final int amount;
  final ExpenseCategory category;
  final DateTime date;
  final String note;

  @override
  List<Object?> get props => [id, title, amount, category, date, note];
}
