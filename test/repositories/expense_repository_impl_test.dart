import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/data/datasources/mock_expense_data_source.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/domain/models/expense.dart';

void main() {
  ExpenseModel make(String id, DateTime date) => ExpenseModel(
        id: id,
        title: 'Item $id',
        amount: 1000,
        category: ExpenseCategory.lainnya,
        date: date,
      );

  test('getExpenses mengurutkan dari tanggal terbaru', () async {
    final repo = ExpenseRepositoryImpl(
      MockExpenseDataSource(seed: [
        make('lama', DateTime(2026, 1, 1)),
        make('baru', DateTime(2026, 11, 1)),
      ]),
    );

    final result = await repo.getExpenses();

    expect(result.map((e) => e.id), ['baru', 'lama']);
  });

  test('add lalu get mengembalikan data yang disimpan', () async {
    final repo = ExpenseRepositoryImpl(MockExpenseDataSource());

    await repo.addExpense(make('1', DateTime(2026, 11, 18)));

    expect((await repo.getExpenses()).single.id, '1');
  });

  test('StorageException -> StorageFailure', () async {
    final repo = ExpenseRepositoryImpl(
      MockExpenseDataSource(errorToThrow: const StorageException()),
    );

    expect(repo.getExpenses(), throwsA(isA<StorageFailure>()));
  });

  test('MalformedDataException -> MalformedDataFailure', () async {
    final repo = ExpenseRepositoryImpl(
      MockExpenseDataSource(errorToThrow: const MalformedDataException()),
    );

    expect(repo.getExpenses(), throwsA(isA<MalformedDataFailure>()));
  });

  test('NetworkException -> NetworkFailure', () async {
    final repo = ExpenseRepositoryImpl(
      MockExpenseDataSource(errorToThrow: const NetworkException()),
    );

    expect(repo.getExpenses(), throwsA(isA<NetworkFailure>()));
  });

  test('operasi lambat -> TimeoutFailure', () async {
    final repo = ExpenseRepositoryImpl(
      MockExpenseDataSource(delay: const Duration(milliseconds: 200)),
      timeout: const Duration(milliseconds: 20),
    );

    expect(repo.getExpenses(), throwsA(isA<TimeoutFailure>()));
  });

  test('ubah data yang tidak ada -> NotFoundFailure', () async {
    final repo = ExpenseRepositoryImpl(MockExpenseDataSource());

    expect(
      repo.updateExpense(make('x', DateTime(2026, 1, 1))),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('error tak dikenal -> UnknownFailure (bukan raw exception)', () async {
    final repo = ExpenseRepositoryImpl(
      MockExpenseDataSource(errorToThrow: StateError('boom')),
    );

    expect(repo.getExpenses(), throwsA(isA<UnknownFailure>()));
  });

  test('semua pesan Failure ramah pengguna', () {
    const failures = <Failure>[
      StorageFailure(),
      MalformedDataFailure(),
      NotFoundFailure(),
      NetworkFailure(),
      TimeoutFailure(),
      UnknownFailure(),
    ];
    for (final f in failures) {
      expect(f.message, isNot(contains('Exception')));
      expect(f.message, isNot(contains('SQL')));
    }
  });
}
