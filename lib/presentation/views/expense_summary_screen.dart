import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/domain/models/expense_summary.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_summary_view_model.dart';
import 'package:expense_tracker/presentation/views/widgets/empty_view.dart';
import 'package:expense_tracker/presentation/views/widgets/error_view.dart';
import 'package:expense_tracker/presentation/views/widgets/summary_card.dart';

class ExpenseSummaryScreen extends StatelessWidget {
  const ExpenseSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpenseSummaryViewModel>(
      create: (_) => GetIt.I<ExpenseSummaryViewModel>()..load(),
      child: const _ExpenseSummaryView(),
    );
  }
}

class _ExpenseSummaryView extends StatelessWidget {
  const _ExpenseSummaryView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseSummaryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Pengeluaran')),
      body: switch (viewModel.state) {
        InitialState() || LoadingState() =>
          const Center(child: CircularProgressIndicator()),
        EmptyState() => const EmptyView(),
        SuccessState(:final data) => _SummaryContent(summary: data),
        ErrorState(:final message) =>
          ErrorView(message: message, onRetry: viewModel.load),
      },
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary});

  final ExpenseSummary summary;

  @override
  Widget build(BuildContext context) {
    final entries = summary.totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      children: [
        SummaryCard(
          label: 'Total dari ${summary.count} transaksi',
          value: formatRupiah(summary.total),
        ),
        for (final entry in entries)
          ListTile(
            title: Text(entry.key.label),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(value: entry.value / summary.total),
            ),
            trailing: Text(
              formatRupiah(entry.value),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
