import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_list_view_model.dart';
import 'package:expense_tracker/presentation/views/add_edit_expense_screen.dart';
import 'package:expense_tracker/presentation/views/expense_summary_screen.dart';
import 'package:expense_tracker/presentation/views/widgets/empty_view.dart';
import 'package:expense_tracker/presentation/views/widgets/error_view.dart';
import 'package:expense_tracker/presentation/views/widgets/expense_card.dart';
import 'package:expense_tracker/presentation/views/widgets/summary_card.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpenseListViewModel>(
      create: (_) => GetIt.I<ExpenseListViewModel>()..load(),
      child: const _ExpenseListView(),
    );
  }
}

class _ExpenseListView extends StatelessWidget {
  const _ExpenseListView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatat Pengeluaran'),
        actions: [
          IconButton(
            tooltip: 'Ringkasan',
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ExpenseSummaryScreen(),
              ),
            ),
          ),
        ],
      ),

      body: switch (viewModel.state) {
        InitialState() || LoadingState() =>
          const Center(child: CircularProgressIndicator()),
        EmptyState() => const EmptyView(),
        SuccessState(:final data) => _ExpenseList(expenses: data),
        ErrorState(:final message) =>
          ErrorView(message: message, onRetry: viewModel.load),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold<int>(0, (sum, e) => sum + e.amount);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: expenses.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return SummaryCard(
            label: 'Total pengeluaran',
            value: formatRupiah(total),
          );
        }
        final expense = expenses[index - 1];
        return ExpenseCard(
          expense: expense,
          onTap: () => _openForm(context, expense: expense),
          onDelete: () => _confirmDelete(context, expense),
        );
      },
    );
  }
}

Future<void> _openForm(BuildContext context, {Expense? expense}) async {
  final viewModel = context.read<ExpenseListViewModel>();
  final messenger = ScaffoldMessenger.of(context);
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => AddEditExpenseScreen(expense: expense),
    ),
  );
  if (saved == true) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Pengeluaran berhasil disimpan.')),
    );
    await viewModel.load();
  }
}

Future<void> _confirmDelete(BuildContext context, Expense expense) async {
  final viewModel = context.read<ExpenseListViewModel>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Hapus pengeluaran?'),
      content: Text('"${expense.title}" akan dihapus permanen.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await viewModel.deleteExpense(expense.id);
  }
}
