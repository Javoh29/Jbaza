import 'dart:convert';
import 'dart:io';

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
      _errorsList = await getBoxAllValue<VMException>(errorLogKey) ?? [];
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

  Future<void> deleteAllError() async {
    setBusy(true);
    try {
      _errorsList.clear();
      _filterErrorsList.clear();
      await deleteLazyBoxKey<VMException>(errorLogKey);
      setSuccess();
    } catch (e) {
      setError(VMException(e.toString(), callFuncName: 'deleteAllError'));
    }
  }

  Future<void> shareError(List<VMException> list) async {
    try {
      var dir = await getAppDirPath();
      final filePath = '${dir!.path}/jbaza_errors.json';
      final File file = File(filePath);
      List<VMException> vmeList = [];
      vmeList.addAll(list);
      vmeList.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(vmeList));
      jbShare(path: filePath, isFile: true);
    } catch (e) {
      setError(VMException(e.toString(), callFuncName: 'shareError'));
    }
  }
}
