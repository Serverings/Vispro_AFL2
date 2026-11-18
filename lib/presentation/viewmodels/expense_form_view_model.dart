import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/state/view_state.dart';
import 'package:expense_tracker/domain/models/expense.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/domain/validators/expense_validator.dart';
import 'package:expense_tracker/presentation/viewmodels/base_view_model.dart';

/// Form tambah/ubah pengeluaran.
/// Alur: Initial -> (validasi gagal) Error | (valid) Loading -> Success | Error.
class ExpenseFormViewModel extends BaseViewModel<Expense> {
  ExpenseFormViewModel(this._repository);

  static const String _invalidInputMessage = 'Periksa kembali isian Anda.';

  final ExpenseRepository _repository;

  /// Dipanggil saat pengguna memperbaiki input setelah error.
  void reset() {
    if (state is ErrorState<Expense>) emit(const InitialState());
  }

  Future<void> submit({
    required String title,
    required String amountText,
    required ExpenseCategory category,
    required DateTime date,
    String note = '',
    Expense? editing,
  }) async {
    if (state is LoadingState<Expense>) return;

    // Validasi sinkron: tidak melewati LoadingState.
    final errors = ExpenseValidator.validateInput(
      title: title,
      amountText: amountText,
    );
    if (errors.isNotEmpty) {
      emit(ErrorState(_invalidInputMessage, fieldErrors: errors));
      return;
    }

    final expense = Expense(
      id: editing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      amount: int.parse(amountText.trim()),
      category: category,
      date: date,
      note: note.trim(),
    );

    emit(const LoadingState());
    try {
      if (editing == null) {
        await _repository.addExpense(expense);
      } else {
        await _repository.updateExpense(expense);
      }
      if (isClosed) return;
      emit(SuccessState(expense));
    } on ValidationFailure catch (failure) {
      if (isClosed) return;
      emit(ErrorState(failure.message, fieldErrors: failure.fieldErrors));
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(ErrorState(failure.message));
    } catch (_) {
      if (isClosed) return;
      emit(ErrorState(const UnknownFailure().message));
    }
  }
}