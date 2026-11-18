import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/presentation/viewmodels/base_view_model.dart';

class ExpenseListViewModel extends BaseViewModel<List<Expense>> {
  ExpenseListViewModel(this._repository);

  final ExpenseRepository _repository;

  Future<void> load() async {
    emit(const LoadingState());
    try {
      final items = await _repository.getExpenses();
      if (isClosed) return;
      emit(items.isEmpty ? const EmptyState() : SuccessState(items));
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(ErrorState(failure.message));
    } catch (_) {
      if (isClosed) return;
      emit(ErrorState(const UnknownFailure().message));
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      if (isClosed) return;
      await load();
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(ErrorState(failure.message));
    } catch (_) {
      if (isClosed) return;
      emit(ErrorState(const UnknownFailure().message));
    }
  }
}
