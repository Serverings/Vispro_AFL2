import 'dart:async';

import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/utils/app_logger.dart';
import 'package:expense_tracker/data/datasources/expense_data_source.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/domain/validators/expense_validator.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(
    this._dataSource, {
    this.timeout = const Duration(seconds: 5),
    this.logger = logError,
  });

  final ExpenseDataSource _dataSource;
  final Duration timeout;
  final ErrorLogger logger;

  @override
  Future<List<Expense>> getExpenses() => _guard('getExpenses', () async {
        final models = await _dataSource.getAll();
        final sorted = List<Expense>.of(models)
          ..sort((a, b) => b.date.compareTo(a.date));
        return sorted;
      });

  @override
  Future<void> addExpense(Expense expense) => _guard('addExpense', () async {
        _ensureValid(expense);
        await _dataSource.insert(ExpenseModel.fromExpense(expense));
      });

  @override
  Future<void> updateExpense(Expense expense) =>
      _guard('updateExpense', () async {
        _ensureValid(expense);
        await _dataSource.update(ExpenseModel.fromExpense(expense));
      });

  @override
  Future<void> deleteExpense(String id) =>
      _guard('deleteExpense', () => _dataSource.delete(id));

  void _ensureValid(Expense expense) {
    final errors = ExpenseValidator.validateExpense(expense);
    if (errors.isNotEmpty) throw ValidationFailure(errors);
  }

  Future<T> _guard<T>(String operation, Future<T> Function() action) async {
    try {
      return await action().timeout(timeout);
    } on Failure {
      rethrow;
    } on TimeoutException catch (e, st) {
      logger(operation, e, st);
      throw const TimeoutFailure();
    } on NetworkException catch (e, st) {
      logger(operation, e, st);
      throw const NetworkFailure();
    } on MalformedDataException catch (e, st) {
      logger(operation, e, st);
      throw const MalformedDataFailure();
    } on NotFoundException catch (e, st) {
      logger(operation, e, st);
      throw const NotFoundFailure();
    } on StorageException catch (e, st) {
      logger(operation, e, st);
      throw const StorageFailure();
    } catch (e, st) {
      logger(operation, e, st);
      throw const UnknownFailure();
    }
  }
}