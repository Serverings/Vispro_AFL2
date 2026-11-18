import 'package:expense_tracker/domain/models/expense.dart';

abstract final class ExpenseValidator {
  static const String titleField = 'title';
  static const String amountField = 'amount';

  static const int maxTitleLength = 50;
  static const int maxAmount = 1000000000000;
  static Map<String, String> validateInput({
    required String title,
    required String amountText,
  }) {
    final errors = <String, String>{};

    final titleError = _titleError(title.trim());
    if (titleError != null) errors[titleField] = titleError;

    final cleanAmount = amountText.trim();
    if (cleanAmount.isEmpty) {
      errors[amountField] = 'Nominal tidak boleh kosong.';
    } else {
      final amount = int.tryParse(cleanAmount);
      if (amount == null) {
        errors[amountField] = 'Nominal harus berupa angka.';
      } else {
        final amountError = _amountError(amount);
        if (amountError != null) errors[amountField] = amountError;
      }
    }
    return errors;
  }

  static Map<String, String> validateExpense(Expense expense) {
    final errors = <String, String>{};

    final titleError = _titleError(expense.title.trim());
    if (titleError != null) errors[titleField] = titleError;

    final amountError = _amountError(expense.amount);
    if (amountError != null) errors[amountField] = amountError;

    return errors;
  }

  static String? _titleError(String title) {
    if (title.isEmpty) return 'Judul pengeluaran tidak boleh kosong.';
    if (title.length > maxTitleLength) {
      return 'Judul terlalu panjang (maksimal 50 karakter).';
    }
    return null;
  }

  static String? _amountError(int amount) {
    if (amount <= 0) return 'Nominal harus lebih dari 0.';
    if (amount > maxAmount) return 'Nominal terlalu besar.';
    return null;
  }
}