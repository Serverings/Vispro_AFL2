import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/domain/validators/expense_validator.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_form_view_model.dart';

class AddEditExpenseScreen extends StatelessWidget {
  const AddEditExpenseScreen({super.key, this.expense});

  final Expense? expense;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpenseFormViewModel>(
      create: (_) => GetIt.I<ExpenseFormViewModel>(),
      child: _ExpenseFormView(expense: expense),
    );
  }
}

class _ExpenseFormView extends StatefulWidget {
  const _ExpenseFormView({required this.expense});

  final Expense? expense;

  @override
  State<_ExpenseFormView> createState() => _ExpenseFormViewState();
}

class _ExpenseFormViewState extends State<_ExpenseFormView> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final ValueNotifier<ExpenseCategory> _category;
  late final ValueNotifier<DateTime> _date;
  late final ExpenseFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController =
        TextEditingController(text: e == null ? '' : e.amount.toString());
    _noteController = TextEditingController(text: e?.note ?? '');
    _category = ValueNotifier<ExpenseCategory>(
      e?.category ?? ExpenseCategory.makanan,
    );
    _date = ValueNotifier<DateTime>(e?.date ?? DateTime.now());
    _viewModel = context.read<ExpenseFormViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _category.dispose();
    _date.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    if (_viewModel.state is SuccessState<Expense>) {
      Navigator.of(context).pop(true);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    unawaited(
      _viewModel.submit(
        title: _titleController.text,
        amountText: _amountController.text,
        category: _category.value,
        date: _date.value,
        note: _noteController.text,
        editing: widget.expense,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    _date.value = picked;
    _viewModel.reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseFormViewModel>().state;
    final isLoading = state is LoadingState<Expense>;
    final fieldErrors = switch (state) {
      ErrorState(fieldErrors: final errors) => errors,
      _ => const <String, String>{},
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StateBanner(state: state),
            TextField(
              controller: _titleController,
              enabled: !isLoading,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Judul',
                errorText: fieldErrors[ExpenseValidator.titleField],
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _viewModel.reset(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              enabled: !isLoading,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp ',
                errorText: fieldErrors[ExpenseValidator.amountField],
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _viewModel.reset(),
            ),
            const SizedBox(height: 16),
            const Text('Kategori'),
            const SizedBox(height: 8),
            ValueListenableBuilder<ExpenseCategory>(
              valueListenable: _category,
              builder: (context, selected, _) => Wrap(
                spacing: 8,
                children: [
                  for (final c in ExpenseCategory.values)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: selected == c,
                      onSelected: isLoading
                          ? null
                          : (_) {
                              _category.value = c;
                              _viewModel.reset();
                            },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<DateTime>(
              valueListenable: _date,
              builder: (context, date, _) => OutlinedButton.icon(
                onPressed: isLoading ? null : _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(formatDate(date)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              enabled: !isLoading,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateBanner extends StatelessWidget {
  const _StateBanner({required this.state});

  final ViewState<Expense> state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (state) {
      InitialState() || EmptyState() || SuccessState() =>
        const SizedBox.shrink(),
      LoadingState() => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LinearProgressIndicator(),
        ),
      ErrorState(:final message, :final fieldErrors) => fieldErrors.isNotEmpty
          ? const SizedBox.shrink()
          : Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
    };
  }
}