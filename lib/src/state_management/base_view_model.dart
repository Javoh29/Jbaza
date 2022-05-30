import 'package:flutter/material.dart';
import 'package:jbaza/src/utils/hive_util.dart';
import 'package:jbaza/src/widgets/info_dialog.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../utils/initial_util.dart';
import '../utils/view_model_exception.dart';

/// Contains ViewModel functionality for busy state management
abstract class BaseViewModel extends ChangeNotifier with HiveUtil {
  BaseViewModel({String? tag, this.context}) {
    _modelTag = tag ?? 'BaseViewModel';
  }

  final Map<String, bool> _busyStates = <String, bool>{};
  final Map<String, VMException> _errorStates = <String, VMException>{};
  final Map<String, dynamic> _successStates = <String, dynamic>{};

  final String errorLogKey = 'jbaza_error_log';
  BuildContext? context;
  late String _modelTag;
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
    String mTag = tag ?? _modelTag;
    _busyStates[mTag] = value;
    _errorStates.remove(mTag);
    _successStates.remove(mTag);
    if (change) notifyListeners();
  }

  void setError(VMException value,
      {String? tag, bool change = true, bool save = true}) {
    value.tag = tag ?? modelTag;
    var curTime = DateTime.now();
    value.time = curTime.toIso8601String();
    _errorStates[value.tag] = value;
    _busyStates.remove(value.tag);
    _successStates.remove(value.tag);
    if (change) notifyListeners();
    if (save) _sendToSave(value);
  }

  void setSuccess({dynamic value, String? tag, bool change = true}) {
    value ??= true;
    String mTag = tag ?? modelTag;
    _successStates[mTag] = value;
    _busyStates.remove(mTag);
    _errorStates.remove(mTag);
    if (change) notifyListeners();
  }

  Future<void> _sendToSave(VMException value) async {
    value.deviceInfo = deviceInfo;
    addLazyBox<VMException>(errorLogKey, value);
    if (isEnableSentry) {
      Sentry.captureMessage(value.toJson().toString(),
          level: SentryLevel.error);
    }
  }

  VMException? getVMError({String? tag}) => _errorStates[tag ?? _modelTag];

  dynamic getVMResponse({String? tag}) => _successStates[tag ?? _modelTag];

  void setInitialised(bool value) => _initialised = value;

  void setOnModelReadyCalled(bool value) => _onModelReadyCalled = value;

  shwoInfo(String text,
      {TextStyle? kTextStyle,
      Color? bgColor,
      int? durTime,
      SnackBarAction? barAction,
      String? dTitle,
      List<Widget>? dActions,
      bool isShowMoreD = true,
      bool isCancelBtnD = false,
      bool isDialog = false}) {
    if (context != null) {
      if (isDialog) {
        showInfoDialog(context!, text,
            title: dTitle,
            btns: dActions,
            isShowMore: isShowMoreD,
            isCancelBtn: isCancelBtnD);
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
            duration: Duration(milliseconds: durTime ?? 4000),
            action: barAction,
            content: Text(
              text,
              style: kTextStyle ??
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            backgroundColor: bgColor ?? Colors.redAccent));
      }
    }
  }

  @override
  void notifyListeners() {
    if (!disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _busyStates.clear();
    _errorStates.clear();
    _successStates.clear();
    context = null;
    super.dispose();
  }
}

/// Interface: Additional actions that should be implemented by spcialised ViewModels
abstract class Initialisable {
  void initialise();
}
