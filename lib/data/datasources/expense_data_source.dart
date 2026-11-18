import 'package:expense_tracker/data/models/expense_model.dart';

abstract class ExpenseDataSource {
  Future<List<ExpenseModel>> getAll();
  Future<void> insert(ExpenseModel expense);
  Future<void> update(ExpenseModel expense);
  Future<void> delete(String id);
}
