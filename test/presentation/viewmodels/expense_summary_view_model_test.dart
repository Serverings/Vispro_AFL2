import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/domain/models/expense_summary.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_summary_view_model.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  final sample = Expense(
    id: '1',
    title: 'Makan',
    amount: 20000,
    category: ExpenseCategory.makanan,
    date: DateTime(2026, 11, 18),
  );

  late MockExpenseRepository repository;
  late ExpenseSummaryViewModel viewModel;
  late List<ViewState<ExpenseSummary>> states;

  setUp(() {
    repository = MockExpenseRepository();
    viewModel = ExpenseSummaryViewModel(repository);
    states = [];
    viewModel.addListener(() => states.add(viewModel.state));
  });

  test('sukses: Loading lalu Success berisi ringkasan', () async {
    when(() => repository.getExpenses()).thenAnswer((_) async => [sample]);

    await viewModel.load();

    expect(states.first, const LoadingState<ExpenseSummary>());
    final last = states.last as SuccessState<ExpenseSummary>;
    expect(last.data.total, 20000);
  });

  test('data kosong: EmptyState', () async {
    when(() => repository.getExpenses()).thenAnswer((_) async => []);

    await viewModel.load();

    expect(states.last, const EmptyState<ExpenseSummary>());
  });

  test('gagal: ErrorState dengan pesan ramah pengguna', () async {
    when(() => repository.getExpenses())
        .thenAnswer((_) async => throw const MalformedDataFailure());

    await viewModel.load();

    final last = states.last as ErrorState<ExpenseSummary>;
    expect(last.message, const MalformedDataFailure().message);
  });

  test('guard isClosed: dispose saat await tidak melempar error', () async {
    final completer = Completer<List<Expense>>();
    when(() => repository.getExpenses()).thenAnswer((_) => completer.future);

    final future = viewModel.load();
    viewModel.dispose();
    completer.complete([sample]);

    await expectLater(future, completes);
  });
}
