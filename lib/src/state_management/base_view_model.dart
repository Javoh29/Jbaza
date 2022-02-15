import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:jbaza/src/utils/view_model_response.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../utils/initial_util.dart';
import '../utils/view_model_exception.dart';

/// Contains ViewModel functionality for busy state management
abstract class BaseViewModel extends ChangeNotifier {
  final Map<String, bool> _busyStates = <String, bool>{};
  final Map<String, VMException> _errorStates = <String, VMException>{};
  final Map<String, VMResponse> _successStates = <String, VMResponse>{};

  final String errorLogKey = 'jbaza_error_log';
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
    var curTime = DateTime.now();
    value.time =
        '${curTime.day}-${curTime.month}-${curTime.year} (${curTime.hour}:${curTime.minute})';
    _errorStates[value.tag] = value;
    _busyStates.remove(value.tag);
    if (change) notifyListeners();
    _sendToSave(value);
  }

  void setSuccess({VMResponse? value, String? tag, bool change = true}) {
    value ??= VMResponse(true);
    value.tag = tag ?? modelTag;
    _successStates[value.tag] = value;
    _busyStates.remove(value.tag);
    if (change) notifyListeners();
  }

  Future<void> _sendToSave(VMException value) async {
    String deviceInfo = 'Unknown device, AppVersion: $mAppVersion';
    try {
      if (Platform.isIOS) {
        var iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceInfo =
            'Dev: ${iosInfo.name} - ${iosInfo.model}, OS: ${Platform.operatingSystem} ${iosInfo.systemVersion}, AppVersion: $mAppVersion';
      } else if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceInfo =
            'Dev: ${androidInfo.manufacturer} - ${androidInfo.model}, OS: ${Platform.operatingSystem} ${androidInfo.version.release}, AppVersion: $mAppVersion';
      }
    } catch (e) {
      Sentry.captureMessage(e.toString(), level: SentryLevel.error);
    }
    value.deviceInfo = deviceInfo;
    saveLazyBox<VMException>(errorLogKey, value);
    Sentry.captureMessage(value.toJson().toString(), level: SentryLevel.error);
  }

  VMException? getVMError({String? tag}) => _errorStates[tag ?? _modelTag];

  VMResponse? getVMResponse({String? tag}) => _successStates[tag ?? _modelTag];

  void setInitialised(bool value) => _initialised = value;

  void setOnModelReadyCalled(bool value) => _onModelReadyCalled = value;

  Future<void> replaceBox<T>(String key, T data) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key);
    }
    box.put(key, data);
    if (T is HiveObject) {
      (data as HiveObject).save();
    }
  }

  Future<void> saveBox<T>(String key, T data) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key);
    }
    box.add(data);
  }

  Future<void> saveLazyBox<T>(String key, T data) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox<T>(key);
    } else {
      box = await Hive.openLazyBox<T>(key);
    }
    box.add(data);
  }

  Future<T> getBox<T>(String key) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key);
    }
    return Future<T>.value(box.get(key));
  }

  Future<T> getLazyBox<T>(String key) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox<T>(key);
    } else {
      box = await Hive.openLazyBox<T>(key);
    }
    T? value = await box.get(key);
    return Future<T>.value(value);
  }

  Future<List<T>> getBoxAllValue<T>(String key) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key);
    }
    return Future<List<T>>.value(box.toMap().values.toList());
  }

  Future<List<T>> getLazyBoxAllValue<T>(String key) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox<T>(key);
    } else {
      box = await Hive.openLazyBox<T>(key);
    }
    List<T> list = [];
    for (var e in box.keys) {
      T? v = await box.get(e);
      if (v != null) list.add(v);
    }
    return Future<List<T>>.value(list);
  }

  Future<void> deleteBox(String key) async {
    Box box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box(key);
    } else {
      box = await Hive.openBox(key);
    }
    box.clear();
  }

  Future<void> deleteLazyBox(String key) async {
    LazyBox box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox(key);
    } else {
      box = await Hive.openLazyBox(key);
    }
    box.clear();
  }

  Future<void> deleteBoxKey<T>(key) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box(key);
    } else {
      box = await Hive.openBox(key);
    }
    box.clear();
  }

  Future<void> deleteLazyBoxKey<T>(key) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox(key);
    } else {
      box = await Hive.openLazyBox(key);
    }
    box.clear();
  }

  Future<void> closeBox(String key) async {
    try {
      final Box box = await Hive.openBox(key);
      box.close();
    } catch (e) {
      Sentry.captureMessage(e.toString(), level: SentryLevel.error);
    }
  }

  Future<void> closeLazyBox(String key) async {
    try {
      final LazyBox box = await Hive.openLazyBox(key);
      box.close();
    } catch (e) {
      Sentry.captureMessage(e.toString(), level: SentryLevel.error);
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
    Hive.close();
    super.dispose();
  }
}

/// Interface: Additional actions that should be implemented by spcialised ViewModels
abstract class Initialisable {
  void initialise();
}
