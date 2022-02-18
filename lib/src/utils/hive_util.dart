
import 'package:hive/hive.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin HiveUtil {
  Future<void> saveBox<T>(String key, T data, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.put(key, data);
    if (T is HiveObject) {
      (data as HiveObject).save();
    }
  }

  Future<void> addBox<T>(String key, T data, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.add(data);
  }

  Future<void> addLazyBox<T>(String key, T data, {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox<T>(key);
    } else {
      box = await Hive.openLazyBox<T>(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.add(data);
  }

  Future<T?> getBox<T>(String key, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    return Future<T?>.value(box.get(key));
  }

  Future<T?> getLazyBox<T>(String key, {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox<T>(key);
    } else {
      box = await Hive.openLazyBox<T>(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    T? value = await box.get(key);
    return Future<T?>.value(value);
  }

  Future<List<T>?> getBoxAllValue<T>(String key, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    return Future<List<T>?>.value(box.toMap().values.toList());
  }

  Future<List<T>?> getLazyBoxAllValue<T>(String key,
      {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox<T>(key);
    } else {
      box = await Hive.openLazyBox<T>(key,
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

  Future<void> deleteBox(String key, {List<int>? encrypKey}) async {
    Box box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box(key);
    } else {
      box = await Hive.openBox(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.clear();
  }

  Future<void> deleteLazyBox(String key, {List<int>? encrypKey}) async {
    LazyBox box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox(key);
    } else {
      box = await Hive.openLazyBox(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.clear();
  }

  Future<void> deleteBoxKey<T>(key, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box(key);
    } else {
      box = await Hive.openBox<T>(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.clear();
  }

  Future<void> deleteLazyBoxKey<T>(key, {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.lazyBox(key);
    } else {
      box = await Hive.openLazyBox<T>(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    box.clear();
  }

  Future<void> closeBox(String key, {List<int>? encrypKey}) async {
    try {
      final Box box = await Hive.openBox(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
      box.close();
    } catch (e) {
      Sentry.captureMessage(e.toString(), level: SentryLevel.error);
    }
  }

  Future<void> closeLazyBox(String key, {List<int>? encrypKey}) async {
    try {
      final LazyBox box = await Hive.openLazyBox(key,
          encryptionCipher:
              encrypKey != null ? HiveAesCipher(encrypKey) : null);
      box.close();
    } catch (e) {
      Sentry.captureMessage(e.toString(), level: SentryLevel.error);
    }
  }
}