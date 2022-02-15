import 'package:jbaza/jbaza.dart';

class ErrorsViewModel extends BaseViewModel {
  List<VMException> _errorsList = [];
  final List<VMException> _filterErrorsList = [];
  List<VMException> get errorsList =>
      isFilter ? _filterErrorsList : _errorsList;

  List<VMException> selectedList = [];

  bool isFilter = false;

  Future<void> getAllErrors() async {
    setBusy(true);
    try {
      _errorsList = await getBoxAllValue<VMException>(errorLogKey);
      _errorsList = _errorsList.reversed.toList();
      setSuccess();
    } catch (e) {
      setError(VMException(e.toString(), callFuncName: 'getAllErrors'));
    }
  }

  Future<void> searchError(String text) async {
    setBusy(true);
    try {
      _filterErrorsList.clear();
      for (var e in _errorsList) {
        if (e.callFuncName != null &&
            e.callFuncName!.toLowerCase().contains(text)) {
          _filterErrorsList.add(e);
        }
      }
      isFilter = true;
      setSuccess();
    } catch (e) {
      setError(VMException(e.toString(), callFuncName: 'searchError'));
    }
  }
}
