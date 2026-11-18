import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_form_view_model.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  final existing = Expense(
    id: 'abc',
    title: 'Bensin',
    amount: 50000,
    category: ExpenseCategory.transportasi,
    date: DateTime(2026, 11, 17),
  );

  late MockExpenseRepository repository;
  late ExpenseFormViewModel viewModel;
  late List<ViewState<Expense>> states;

  setUpAll(() => registerFallbackValue(existing));

  setUp(() {
    repository = MockExpenseRepository();
    viewModel = ExpenseFormViewModel(repository);
    states = [];
    viewModel.addListener(() => states.add(viewModel.state));
  });

  Future<void> submit({
    String title = 'Makan',
    String amount = '10000',
    Expense? editing,
  }) =>
      viewModel.submit(
        title: title,
        amountText: amount,
        category: ExpenseCategory.makanan,
        date: DateTime(2026, 11, 18),
        editing: editing,
      );

  test('judul kosong: langsung ErrorState tanpa LoadingState', () async {
    await submit(title: '   ');

    expect(states, [
      const ErrorState<Expense>('Judul pengeluaran tidak boleh kosong.'),
    ]);
    verifyNever(() => repository.addExpense(any()));
  });

  test('nominal kosong, bukan angka, nol, atau negatif ditolak', () async {
    for (final bad in ['', 'abc', '0', '-5']) {
      states.clear();
      await submit(amount: bad);
      expect(states.single, isA<ErrorState<Expense>>(), reason: bad);
    }
    verifyNever(() => repository.addExpense(any()));
  });

  test('tambah sukses: Loading lalu Success', () async {
    when(() => repository.addExpense(any())).thenAnswer((_) async {});

    await submit();

    expect(states.first, const LoadingState<Expense>());
    expect(states.last, isA<SuccessState<Expense>>());
    verify(() => repository.addExpense(any())).called(1);
  });

  test('mode ubah memanggil updateExpense dengan id yang sama', () async {
    when(() => repository.updateExpense(any())).thenAnswer((_) async {});

    await submit(editing: existing);

    final captured = verify(() => repository.updateExpense(captureAny()))
        .captured
        .single as Expense;
    expect(captured.id, 'abc');
    verifyNever(() => repository.addExpense(any()));
  });

  test('gagal simpan: ErrorState dengan pesan ramah pengguna', () async {
    when(() => repository.addExpense(any()))
        .thenAnswer((_) async => throw const StorageFailure());

    await submit();

    final last = states.last as ErrorState<Expense>;
    expect(last.message, const StorageFailure().message);
    expect(last.message, isNot(contains('Exception')));
  });

  test('reset dari ErrorState kembali ke InitialState', () async {
    await submit(title: '');
    viewModel.reset();

    expect(viewModel.state, InitialState<Expense>());
  });

  test('guard isClosed: dispose saat menyimpan tidak melempar error',
      () async {
    final completer = Completer<void>();
    when(() => repository.addExpense(any()))
        .thenAnswer((_) => completer.future);

    final future = submit();
    viewModel.dispose();
    completer.complete();

    await expectLater(future, completes);
  });
}
