import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/data/datasources/expense_data_source.dart';
import 'package:expense_tracker/data/models/expense_model.dart';

class LocalExpenseDataSource implements ExpenseDataSource {
  LocalExpenseDataSource(this._prefs);

  static const String storageKey = 'expenses_v1';

  final SharedPreferences _prefs;

  @override
  Future<List<ExpenseModel>> getAll() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return <ExpenseModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) throw const MalformedDataException();
      return decoded
          .map((item) =>
              ExpenseModel.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on MalformedDataException {
      rethrow;
    } catch (_) {
      throw const MalformedDataException();
    }
  }

  @override
  Future<void> insert(ExpenseModel expense) async {
    final items = await getAll();
    items.add(expense);
    await _saveAll(items);
  }

  @override
  Future<void> update(ExpenseModel expense) async {
    final items = await getAll();
    final index = items.indexWhere((e) => e.id == expense.id);
    if (index == -1) throw const NotFoundException();
    items[index] = expense;
    await _saveAll(items);
  }

  @override
  Future<void> delete(String id) async {
    final items = await getAll();
    final before = items.length;
    items.removeWhere((e) => e.id == id);
    if (items.length == before) throw const NotFoundException();
    await _saveAll(items);
  }

  Future<void> _saveAll(List<ExpenseModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toMap()).toList());
    final success = await _prefs.setString(storageKey, encoded);
    if (!success) throw const StorageException();
  }
}
