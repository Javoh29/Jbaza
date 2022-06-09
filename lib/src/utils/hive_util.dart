import 'package:jbaza/jbaza.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin HiveUtil {
  Future<void> saveBox<T>(String boxKey, T data, {dynamic key, List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    await box.put(key ?? boxKey, data);
  }

  Future<void> saveLazyBox<T>(String boxKey, T data, {dynamic key, List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox<T>(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    await box.put(key ?? boxKey, data);
  }

  Future<void> addBox<T>(String boxKey, T data, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    await box.add(data);
  }

  Future<void> addLazyBox<T>(String boxKey, T data, {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox<T>(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    await box.add(data);
  }

  Future<T?> getBox<T>(String boxKey, {dynamic key, List<int>? encrypKey, T? defaultValue}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    return Future<T?>.value(box.get(key ?? boxKey, defaultValue: defaultValue));
  }

  Future<T?> getLazyBox<T>(String boxKey, {dynamic key, List<int>? encrypKey, T? defaultValue}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox<T>(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    return Future<T?>.value(box.get(key ?? boxKey, defaultValue: defaultValue));
  }

  Future<List<T>?> getBoxAllValue<T>(String boxKey, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box<T>(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    return Future<List<T>?>.value(box.toMap().values.toList());
  }

  Future<List<T>?> getLazyBoxAllValue<T>(String boxKey, {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox<T>(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
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
      box = await Hive.openBox(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    await box.clear();
  }

  Future<void> deleteLazyBox<T>(String boxKey, {List<int>? encrypKey}) async {
    LazyBox box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox(boxKey);
    } else {
      box = await Hive.openLazyBox(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    await box.clear();
  }

  Future<void> deleteBoxKey<T>(boxKey, key, {List<int>? encrypKey}) async {
    late Box<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.box(boxKey);
    } else {
      box = await Hive.openBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    await box.delete(key);
  }

  Future<void> deleteLazyBoxKey<T>(boxKey, key, {List<int>? encrypKey}) async {
    late LazyBox<T> box;
    if (Hive.isBoxOpen(boxKey)) {
      box = Hive.lazyBox(boxKey);
    } else {
      box = await Hive.openLazyBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
    }
    await box.delete(key);
  }

  Future<void> closeBox<T>(String boxKey, {List<int>? encrypKey}) async {
    try {
      late Box<T> box;
      if (Hive.isBoxOpen(boxKey)) {
        box = Hive.box(boxKey);
      } else {
        box = await Hive.openBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
      }
      await box.close();
    } catch (e) {
      if (isEnableSentry) {
        Sentry.captureMessage(e.toString(), level: SentryLevel.error);
      }
    }
  }

  Future<void> closeLazyBox<T>(String boxKey, {List<int>? encrypKey}) async {
    try {
      late LazyBox<T> box;
      if (Hive.isBoxOpen(boxKey)) {
        box = Hive.lazyBox(boxKey);
      } else {
        box = await Hive.openLazyBox<T>(boxKey, encryptionCipher: encrypKey != null ? HiveAesCipher(encrypKey) : null);
      }
      await box.close();
    } catch (e) {
      if (isEnableSentry) {
        Sentry.captureMessage(e.toString(), level: SentryLevel.error);
      }
    }
  }

  Future<Box<T>?> getHiveBox<T>(String boxKey) async {
    try {
      if (Hive.isBoxOpen(boxKey)) {
        return Hive.box<T>(boxKey);
      } else {
        return Future.value(Hive.openBox<T>(boxKey));
      }
    } catch (e) {
      if (isEnableSentry) {
        Sentry.captureMessage(e.toString(), level: SentryLevel.error);
      }
    }
    return null;
  }

  Future<LazyBox<T>?> getHiveLazyBox<T>(String boxKey) async {
    try {
      if (Hive.isBoxOpen(boxKey)) {
        return Hive.lazyBox<T>(boxKey);
      } else {
        return Future.value(Hive.openLazyBox<T>(boxKey));
      }
    } catch (e) {
      if (isEnableSentry) {
        Sentry.captureMessage(e.toString(), level: SentryLevel.error);
      }
    }
    return null;
  }
}
