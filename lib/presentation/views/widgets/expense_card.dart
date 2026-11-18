import 'package:flutter/material.dart';

import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/domain/models/expense.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  IconData _iconFor(ExpenseCategory category) => switch (category) {
        ExpenseCategory.makanan => Icons.restaurant,
        ExpenseCategory.transportasi => Icons.directions_bus,
        ExpenseCategory.belanja => Icons.shopping_bag,
        ExpenseCategory.tagihan => Icons.receipt,
        ExpenseCategory.hiburan => Icons.movie,
        ExpenseCategory.lainnya => Icons.category,
      };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Icon(_iconFor(expense.category))),
      title: Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${expense.category.label} • ${formatDate(expense.date)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatRupiah(expense.amount),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
