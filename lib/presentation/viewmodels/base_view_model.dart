import 'package:flutter/foundation.dart';

import 'package:expense_tracker/core/state/view_state.dart';

abstract class BaseViewModel<T> extends ChangeNotifier {
  ViewState<T> _state = InitialState<T>();
  bool _isDisposed = false;

  ViewState<T> get state => _state;

  bool get isClosed => _isDisposed;

  @protected
  void emit(ViewState<T> newState) {
    if (_isDisposed) return;
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
