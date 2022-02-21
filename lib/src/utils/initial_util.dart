import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:hive/hive.dart';
import 'package:jbaza/jbaza.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share/share.dart';

String mAppVersion = '0.0.1';
String deviceInfo = 'Unknown device, AppVersion: $mAppVersion';
bool isEnableSentry = false;

Future<void> setupConfigs(Function app, String sentryKey,
    {List<TypeAdapter<dynamic>>? adapters,
    double traces = 0.5,
    String? appVersion,
    bool enableSentry = false}) async {
  if (appVersion != null) mAppVersion = appVersion;
  isEnableSentry = enableSentry;
  adapters ??= [];
  adapters.add(VMExceptionAdapter());
  await _initHive(adapters);
  if (enableSentry) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryKey;
        options.tracesSampleRate = traces;
      },
      appRunner: app(),
    );
  } else {
    app();
  }
  await _getDeviceInfo();
}

Future<void> _initHive([List<TypeAdapter<dynamic>>? adapters]) async {
  final directory = await getApplicationSupportDirectory();
  Hive.init(directory.path);
  adapters?.forEach((element) {
    Hive.registerAdapter(element);
  });
}

Future<void> _getDeviceInfo() async {
  try {
    if (Platform.isIOS) {
      var iosInfo = await getIosDevInfo();
      deviceInfo =
          'Dev: ${iosInfo.name} - ${iosInfo.model}, OS: ${Platform.operatingSystem} ${iosInfo.systemVersion}, AppVersion: $mAppVersion';
    } else if (Platform.isAndroid) {
      var androidInfo = await getAndroidDevInfo();
      deviceInfo =
          'Dev: ${androidInfo.manufacturer} - ${androidInfo.model}, OS: ${Platform.operatingSystem} ${androidInfo.version.release}, AppVersion: $mAppVersion';
    }
  } catch (e) {
    if (isEnableSentry) {
      Sentry.captureMessage(e.toString(), level: SentryLevel.error);
    }
  }
}

Future<void> jbShare(
    {String? text,
    String? path,
    String? fileTitle,
    bool isFile = false}) async {
  if (isFile) {
    if (path == null) throw VMException('Share path null');
    Share.shareFiles([path], text: fileTitle);
  } else {
    if (text == null) throw VMException('Share text null');
    Share.share(text);
  }
}

Future<IosDeviceInfo> getIosDevInfo() => DeviceInfoPlugin().iosInfo;
Future<AndroidDeviceInfo> getAndroidDevInfo() => DeviceInfoPlugin().androidInfo;
