import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/domain/models/expense_summary.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/presentation/viewmodels/base_view_model.dart';

class ExpenseSummaryViewModel extends BaseViewModel<ExpenseSummary> {
  ExpenseSummaryViewModel(this._repository);

  final ExpenseRepository _repository;

  Future<void> load() async {
    emit(const LoadingState());
    try {
      final items = await _repository.getExpenses();
      if (isClosed) return;
      emit(
        items.isEmpty
            ? const EmptyState()
            : SuccessState(ExpenseSummary.fromExpenses(items)),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(ErrorState(failure.message));
    } catch (_) {
      if (isClosed) return;
      emit(ErrorState(const UnknownFailure().message));
    }
  }
}
