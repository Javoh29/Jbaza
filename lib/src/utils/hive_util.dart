
import 'package:hive/hive.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin HiveUtil {
  Future<void> saveBox<T>(String boxKey, T data,
      {String? key, List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.put(key ?? boxKey, data);
    if (T is HiveObject) {
      (data as HiveObject).save();
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

  Future<void> addLazyBox<T>(String boxKey, T data, {List<int>? encrypKey}) async {
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
      {String? key, List<int>? encrypKey}) async {
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
      {String? key, List<int>? encrypKey}) async {
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

  Future<List<T>?> getBoxAllValue<T>(String boxKey, {List<int>? encrypKey}) async {
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

  Future<void> deleteBox(String boxKey, {List<int>? encrypKey}) async {
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

  Future<void> deleteLazyBox(String boxKey, {List<int>? encrypKey}) async {
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

  Future<void> deleteBoxKey<T>(boxKey, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.clear();
  }

  Future<void> deleteLazyBoxKey<T>(boxKey, {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.clear();
  }

  Future<void> closeBox(String boxKey, {List<int>? encrypKey}) async {
    try {
      final Box box = await Hive.openBox(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
      box.close();
    } catch (e) {
      Sentry.captureMessage(e.toString(), level: SentryLevel.error);
    }
  }

  Future<void> closeLazyBox(String boxKey, {List<int>? encrypKey}) async {
    try {
      final LazyBox box = await Hive.openLazyBox(boxKey,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
      box.close();
    } catch (e) {
      Sentry.captureMessage(e.toString(), level: SentryLevel.error);
    }
  }
}