import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/data/datasources/expense_data_source.dart';
import 'package:expense_tracker/data/models/expense_model.dart';

class MockExpenseDataSource implements ExpenseDataSource {
  MockExpenseDataSource({
    List<ExpenseModel>? seed,
    this.delay = Duration.zero,
    this.errorToThrow,
  }) : _items = List<ExpenseModel>.of(seed ?? const <ExpenseModel>[]);

  final List<ExpenseModel> _items;
  Duration delay;
  Object? errorToThrow;

  Future<void> _simulate() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final error = errorToThrow;
    if (error != null) throw error;
  }

  @override
  Future<List<ExpenseModel>> getAll() async {
    await _simulate();
    return List<ExpenseModel>.of(_items);
  }

  @override
  Future<void> insert(ExpenseModel expense) async {
    await _simulate();
    _items.add(expense);
  }

  @override
  Future<void> update(ExpenseModel expense) async {
    await _simulate();
    final index = _items.indexWhere((e) => e.id == expense.id);
    if (index == -1) throw const NotFoundException();
    _items[index] = expense;
  }

  @override
  Future<void> delete(String id) async {
    await _simulate();
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == before) throw const NotFoundException();
  }
}
