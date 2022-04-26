import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../utils/initial_util.dart';
import '../utils/view_model_exception.dart';

/// Contains ViewModel functionality for busy state management
abstract class BaseViewModel extends ChangeNotifier {
  BaseViewModel({String? tag}) {
    _modelTag = tag ?? 'BaseViewModel';
  }

  final Map<String, bool> _busyStates = <String, bool>{};
  final Map<String, VMException> _errorStates = <String, VMException>{};
  final Map<String, dynamic> _successStates = <String, dynamic>{};

  final String errorLogKey = 'jbaza_error_log';
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

  void setError(VMException value, {String? tag, bool change = true}) {
    value.tag = tag ?? modelTag;
    var curTime = DateTime.now();
    value.time =
        '${curTime.day}-${curTime.month}-${curTime.year} (${curTime.hour}:${curTime.minute})';
    _errorStates[value.tag] = value;
    _busyStates.remove(value.tag);
    _successStates.remove(value.tag);
    if (change) notifyListeners();
    _sendToSave(value);
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

  Future<void> saveBox<T>(String boxKey, T data,
      {dynamic key, List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    if (T is HiveObject) {
      (data as HiveObject).save();
    } else {
      box.put(key ?? boxKey, data);
    }
  }

  Future<void> saveLazyBox<T>(String boxKey, T data,
      {dynamic key, List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox<T>(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    if (T is HiveObject) {
      (data as HiveObject).save();
    } else {
      box.put(key ?? boxKey, data);
    }
  }

  Future<void> addBox<T>(String boxKey, T data, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.add(data);
  }

  Future<void> addLazyBox<T>(String boxKey, T data,
      {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox<T>(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.add(data);
  }

  Future<T?> getBox<T>(String boxKey,
      {dynamic key, List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    return Future<T?>.value(box.get(key ?? boxKey));
  }

  Future<T?> getLazyBox<T>(String boxKey,
      {dynamic key, List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox<T>(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    T? value = await box.get(key ?? boxKey);
    return Future<T?>.value(value);
  }

  Future<List<T>?> getBoxAllValue<T>(String boxKey,
      {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    return Future<List<T>?>.value(box.toMap().values.toList());
  }

  Future<List<T>?> getLazyBoxAllValue<T>(String boxKey,
      {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox<T>(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    List<T> list = [];
    for (var e in box.keys) {
      T? v = await box.get(e);
      if (v != null) list.add(v);
    }
    return Future<List<T>?>.value(list);
  }

  Future<void> deleteBox<T>(String boxKey, {List<int>? encrypKey}) async {
    Box box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box(boxKey);
    } else {
      box = await Hive.openBox(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.clear();
  }

  Future<void> deleteLazyBox<T>(String boxKey, {List<int>? encrypKey}) async {
    LazyBox box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox(boxKey);
    } else {
      box = await Hive.openLazyBox(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.clear();
  }

  Future<void> deleteBoxKey<T>(boxKey, key, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.delete(key);
  }

  Future<void> deleteLazyBoxKey<T>(boxKey, key, {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.delete(key);
  }

  Future<void> closeBox(String boxKey, {List<int>? encrypKey}) async {
    try {
      final Box box = await Hive.openBox(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
      box.close();
    } catch (e) {
      if (isEnableSentry) {
        Sentry.captureMessage(e.toString(), level: SentryLevel.error);
      }
    }
  }

  Future<void> closeLazyBox(String boxKey, {List<int>? encrypKey}) async {
    try {
      final LazyBox box = await Hive.openLazyBox(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
      box.close();
    } catch (e) {
      if (isEnableSentry) {
        Sentry.captureMessage(e.toString(), level: SentryLevel.error);
      }
    }
  }

  Future<Box?> getHiveBox(String boxKey) async {
    try {
      if (Hive.isBoxOpen(boxKey)) {
        return Hive.box(boxKey);
      } else {
        return Future.value(Hive.openBox(boxKey));
      }
    } catch (e) {
      if (isEnableSentry) {
        Sentry.captureMessage(e.toString(), level: SentryLevel.error);
      }
    }
    return null;
  }

  Future<LazyBox?> getHiveLazyBox(String boxKey) async {
    try {
      if (Hive.isBoxOpen(boxKey)) {
        return Hive.lazyBox(boxKey);
      } else {
        return Future.value(Hive.openLazyBox(boxKey));
      }
    } catch (e) {
      if (isEnableSentry) {
        Sentry.captureMessage(e.toString(), level: SentryLevel.error);
      }
    }
    return null;
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
    super.dispose();
  }
}

/// Interface: Additional actions that should be implemented by spcialised ViewModels
abstract class Initialisable {
  void initialise();
}
