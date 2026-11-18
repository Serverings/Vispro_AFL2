import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/data/datasources/expense_data_source.dart';
import 'package:expense_tracker/data/datasources/local_expense_data_source.dart';
import 'package:expense_tracker/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_form_view_model.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_list_view_model.dart';
import 'package:expense_tracker/presentation/viewmodels/expense_summary_view_model.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
  sl.registerLazySingleton<ExpenseDataSource>(() => LocalExpenseDataSource(sl()));
  sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(sl()));
  sl.registerFactory<ExpenseListViewModel>(() => ExpenseListViewModel(sl()));
  sl.registerFactory<ExpenseFormViewModel>(() => ExpenseFormViewModel(sl()));
  sl.registerFactory<ExpenseSummaryViewModel>(() => ExpenseSummaryViewModel(sl()));
}
