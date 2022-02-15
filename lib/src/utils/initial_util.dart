import 'dart:io';

import 'package:hive/hive.dart';
import 'package:jbaza/jbaza.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

String mAppVersion = '0.0.1';

Future<void> setupConfigs(Function app, String sentryKey,
    {List<TypeAdapter<dynamic>>? adapters,
    double traces = 0.5,
    String? appVersion}) async {
  if (appVersion != null) mAppVersion = appVersion;
  adapters ??= [];
  adapters.add(VMExceptionAdapter());
  await _initHive(adapters);
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryKey;
      options.tracesSampleRate = traces;
    },
    appRunner: app(),
  );
}

Future<void> _initHive([List<TypeAdapter<dynamic>>? adapters]) async {
  final directory = await getAppDirPath();
  Hive.init(directory!.path);
  adapters?.forEach((element) {
    Hive.registerAdapter(element);
  });
}

Future<Directory?> getAppDirPath({String? value}) async {
  switch (value) {
    case 'library':
      return getLibraryDirectory();
    case 'temporary':
      return getTemporaryDirectory();
    case 'support':
      return getApplicationSupportDirectory();
    case 'documents':
      return getApplicationDocumentsDirectory();
    case 'external':
      return getExternalStorageDirectory();
    case 'downloads':
      return getDownloadsDirectory();
    default:
      return getApplicationSupportDirectory();
  }
}
