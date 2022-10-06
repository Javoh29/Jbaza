import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jbaza/src/utils/hive_util.dart';
import 'package:jbaza/src/widgets/info_dialog.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../utils/initial_util.dart';
import '../utils/view_model_exception.dart';

/// Contains ViewModel functionality for busy state management
abstract class BaseViewModel extends ChangeNotifier with HiveUtil {
  BaseViewModel({String? tag, required this.context}) {
    _modelTag = tag ?? 'BaseViewModel';
  }

  final Map<String, bool> _busyStates = <String, bool>{};
  final Map<String, VMException> _errorStates = <String, VMException>{};
  final Map<String, dynamic> _successStates = <String, dynamic>{};

  final String errorLogKey = 'jbaza_error_log';
  BuildContext? context;
  late String _modelTag;
  String get modelTag => _modelTag;
  set modelTag(String value) => _modelTag = value;

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
    callBackBusy(value, tag);
  }

  void setError(VMException value, {String? tag, bool change = true, bool save = true, bool isCallBack = true}) {
    value.tag = tag ?? modelTag;
    _busyStates.remove(value.tag);
    _successStates.remove(value.tag);
    if (save) {
      var curTime = DateTime.now();
      value.time = curTime.toIso8601String();
      _errorStates[value.tag] = value;
      _sendToSave(value);
    }
    if (isCallBack) callBackError(value.message);
    if (change) notifyListeners();
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
    await addLazyBox<VMException>(errorLogKey, value);
    if (isEnableSentry) {
      Sentry.captureMessage(value.toJson().toString(), level: SentryLevel.error);
    }
  }

  void safeBlock(Function body,
      {bool isChange = true, String? tag, String? callFuncName, bool inProgress = true}) async {
    if (inProgress) {
      setBusy(true, change: isChange, tag: tag);
    }
    try {
      await body();
    } on VMException catch (vm) {
      setError(vm.copyWith(tag: tag, callFuncName: callFuncName), change: isChange);
    } on SocketException {
      setError(VMException('No internet connection!', isInet: true, tag: tag ?? _modelTag, callFuncName: callFuncName),
          change: isChange, save: false);
    } catch (e) {
      setError(
          VMException(
            e.toString(),
            tag: tag ?? _modelTag,
            callFuncName: callFuncName,
          ),
          change: isChange);
    }
  }

  VMException? getVMError({String? tag}) => _errorStates[tag ?? _modelTag];

  dynamic getVMResponse({String? tag}) => _successStates[tag ?? _modelTag];

  void setInitialised(bool value) => _initialised = value;

  void setOnModelReadyCalled(bool value) => _onModelReadyCalled = value;

  callBackBusy(bool value, String? tag) {}

  callBackError(String text) {}

  showInfo(String text,
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
            title: dTitle, btns: dActions, isShowMore: isShowMoreD, isCancelBtn: isCancelBtnD);
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
            duration: Duration(milliseconds: durTime ?? 4000),
            action: barAction,
            content: Text(
              text,
              style: kTextStyle ?? TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            backgroundColor: bgColor ?? Colors.redAccent));
      }
    }
  }

  Future<T?> navigateTo<T extends Object?>(String route,
      {bool isRemoveStack = false, Object? arg, int? waitTime, BuildContext? ctx}) async {
    if (ctx != null || context != null) {
      if (waitTime != null) {
        await Future.delayed(Duration(seconds: waitTime));
      }
      if (isRemoveStack) {
        return Navigator.pushNamedAndRemoveUntil<T>(ctx ?? context!, route, (route) => false, arguments: arg);
      } else {
        return Navigator.pushNamed<T>(ctx ?? context!, route, arguments: arg);
      }
    }
    return Future.value(null);
  }

  pop<T>({T? result, int? waitTime, BuildContext? ctx}) async {
    if (ctx != null || context != null) {
      if (waitTime != null) {
        await Future.delayed(Duration(seconds: waitTime));
      }
      Navigator.pop(ctx ?? context!, result);
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
