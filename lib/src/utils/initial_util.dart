import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> setupConfigs(Function app, String sentryKey, double traces) async {
  await Hive.initFlutter();
  await SentryFlutter.init(
    (options) {
      options.dsn = sentryKey;
      options.tracesSampleRate = traces;
    },
    appRunner: () => app,
  );
}
