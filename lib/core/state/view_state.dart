import 'package:equatable/equatable.dart';

sealed class ViewState<T> extends Equatable {
  const ViewState();

  @override
  List<Object?> get props => const [];
}

final class InitialState<T> extends ViewState<T> {
  const InitialState();
}

final class LoadingState<T> extends ViewState<T> {
  const LoadingState();
}

final class EmptyState<T> extends ViewState<T> {
  const EmptyState();
}

final class SuccessState<T> extends ViewState<T> {
  const SuccessState(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class ErrorState<T> extends ViewState<T> {
  const ErrorState(
    this.message, {
    this.fieldErrors = const <String, String>{},
  });

  final String message;

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}
