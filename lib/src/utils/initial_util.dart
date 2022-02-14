import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

String mAppVersion = '0.0.1';

Future<void> setupConfigs(Function app, String sentryKey,
    {List<TypeAdapter<dynamic>>? adapters,
    double traces = 0.5,
    String? appVersion}) async {
  if (appVersion != null) mAppVersion = appVersion;
  adapters ??= [];
  // adapters.add()
  await _initHive(adapters);
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryKey;
      options.tracesSampleRate = traces;
    },
    appRunner: () => app,
  );
}

Future<void> _initHive([List<TypeAdapter<dynamic>>? adapters]) async {
  final directory = await getApplicationSupportDirectory();
  Hive.init(directory.path);
  adapters?.forEach((TypeAdapter element) {
    Hive.registerAdapter(element);
  });
}
