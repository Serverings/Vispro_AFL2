import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_list_view_model.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  final sample = Expense(
    id: '1',
    title: 'Makan siang',
    amount: 25000,
    category: ExpenseCategory.makanan,
    date: DateTime(2026, 11, 18),
  );

  late MockExpenseRepository repository;
  late ExpenseListViewModel viewModel;
  late List<ViewState<List<Expense>>> states;

  setUp(() {
    repository = MockExpenseRepository();
    viewModel = ExpenseListViewModel(repository);
    states = [];
    viewModel.addListener(() => states.add(viewModel.state));
  });

  test('state awal adalah InitialState', () {
    expect(viewModel.state, InitialState<List<Expense>>());
  });

  test('load sukses: Loading lalu Success berisi data', () async {
    when(() => repository.getExpenses()).thenAnswer((_) async => [sample]);

    await viewModel.load();

    expect(states, [
      const LoadingState<List<Expense>>(),
      SuccessState<List<Expense>>([sample]),
    ]);
  });

  test('load dengan data kosong: Loading lalu EmptyState', () async {
    when(() => repository.getExpenses()).thenAnswer((_) async => []);

    await viewModel.load();

    expect(states, [
      const LoadingState<List<Expense>>(),
      const EmptyState<List<Expense>>(),
    ]);
  });

  test('load gagal: ErrorState berisi pesan ramah pengguna', () async {
    when(() => repository.getExpenses())
        .thenAnswer((_) async => throw const StorageFailure());

    await viewModel.load();

    final last = states.last as ErrorState<List<Expense>>;
    expect(last.message, const StorageFailure().message);
    expect(last.message, isNot(contains('Exception')));
  });

  test('exception tak terduga tetap menjadi pesan ramah', () async {
    when(() => repository.getExpenses())
        .thenAnswer((_) async => throw StateError('boom'));

    await viewModel.load();

    final last = states.last as ErrorState<List<Expense>>;
    expect(last.message, const UnknownFailure().message);
  });

  test('deleteExpense memanggil repository lalu memuat ulang', () async {
    when(() => repository.deleteExpense(any())).thenAnswer((_) async {});
    when(() => repository.getExpenses()).thenAnswer((_) async => []);

    await viewModel.deleteExpense('1');

    verify(() => repository.deleteExpense('1')).called(1);
    expect(states.last, const EmptyState<List<Expense>>());
  });

  test('guard isClosed: dispose saat await berjalan tidak melempar error',
      () async {
    final completer = Completer<List<Expense>>();
    when(() => repository.getExpenses()).thenAnswer((_) => completer.future);

    final future = viewModel.load();
    viewModel.dispose();
    completer.complete([sample]);

    await expectLater(future, completes);
    expect(viewModel.isClosed, isTrue);
  });
}
