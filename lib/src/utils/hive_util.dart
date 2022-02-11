import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

mixin HiveUtil {
  Future<void> save<T>(String key, T data) async {
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

  Future<T> get<T>(String key) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box<T>(key);
    } else {
      box = await Hive.openBox<T>(key);
    }
    return Future<T>.value(box.get(key));
  }

  Future<void> delete(String key) async {
    Box box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box(key);
    } else {
      box = await Hive.openBox(key);
    }
    box.clear();
  }

  Future<void> deleteKey<T>(key) async {
    late Box<T> box;
    if (Hive.isBoxOpen(key)) {
      box = Hive.box(key);
    } else {
      box = await Hive.openBox(key);
    }
    box.clear();
  }

  Future<void> close(String key) async {
    final Box box = await Hive.openBox(key);
    box.close();
  }
}

Future<void> hiveInit() async {
  await Hive.initFlutter();
}
