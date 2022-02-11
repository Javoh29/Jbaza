import 'package:flutter/cupertino.dart';
import 'package:jbaza/src/utils/view_model_response.dart';

import '../utils/view_model_exception.dart';

/// Contains ViewModel functionality for busy state management
abstract class BaseViewModel extends ChangeNotifier {
  final Map<String, bool> _busyStates = <String, bool>{};
  final Map<String, VMException> _errorStates = <String, VMException>{};
  final Map<String, VMResponse> _successStates = <String, VMResponse>{};

  String _modelTag = "BaseViewModel";
  String get modelTag => _modelTag;
  void setModelTag(String value) => _modelTag = value;

  bool _initialised = false;
  bool get initialised => _initialised;

  bool _onModelReadyCalled = false;
  bool get onModelReadyCalled => _onModelReadyCalled;

  bool _disposed = false;
  bool get disposed => _disposed;

  bool isBusy({String? tag}) => _busyStates[tag ?? _modelTag] ?? false;

  bool isError({String? tag}) => _errorStates[tag ?? _modelTag] != null;

  bool isSuccess({String? tag}) => _successStates[tag ?? _modelTag] != null;

  void setBusy(bool value, {String? tag, bool change = true}) {
    _busyStates[tag ?? _modelTag] = value;
    if (change) notifyListeners();
  }

  void setError(VMException value, {String? tag, bool change = true}) {
    value.tag = tag ?? modelTag;
    _errorStates[value.tag] = value;
    if (change) notifyListeners();
  }

  void setSuccess(VMResponse value, {String? tag, bool change = true}) {
    value.tag = tag ?? modelTag;
    _successStates[value.tag] = value;
    if (change) notifyListeners();
  }

  VMException? getVMError({String? tag}) => _errorStates[tag];

  VMResponse? getVMResponse({String? tag}) => _successStates[tag];

  void setInitialised(bool value) => _initialised = value;

  void setOnModelReadyCalled(bool value) => _onModelReadyCalled = value;

  @override
  void notifyListeners() {
    if (!disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Interface: Additional actions that should be implemented by spcialised ViewModels
abstract class Initialisable {
  void initialise();
}
