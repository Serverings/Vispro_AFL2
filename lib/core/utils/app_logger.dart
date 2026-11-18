import 'dart:developer' as developer;

typedef ErrorLogger = void Function(
  String operation,
  Object error,
  StackTrace stackTrace,
);

void logError(String operation, Object error, StackTrace stackTrace) {
  developer.log(
    'Gagal pada $operation',
    name: 'ExpenseTracker',
    error: error,
    stackTrace: stackTrace,
    level: 1000,
  );
}