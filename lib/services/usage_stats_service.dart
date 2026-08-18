import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppUsageStat {
  const AppUsageStat(
      {required this.packageName,
      required this.appName,
      required this.foregroundTime});

  final String packageName;
  final String appName;
  final Duration foregroundTime;

  factory AppUsageStat.fromMap(Map<Object?, Object?> value) => AppUsageStat(
        packageName: value['packageName'] as String? ?? '',
        appName: value['appName'] as String? ?? 'Unknown app',
        foregroundTime: Duration(
          milliseconds: (value['foregroundTime'] as num?)?.toInt() ?? 0,
        ),
      );
}

class UsageStatsService {
  UsageStatsService._();

  static const _channel = MethodChannel('carmelitas/usage_stats');
  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<bool> hasPermission() async =>
      isSupported &&
      (await _channel.invokeMethod<bool>('hasPermission') ?? false);

  static Future<void> openPermissionSettings() async {
    if (isSupported)
      await _channel.invokeMethod<void>('openPermissionSettings');
  }

  static Future<List<AppUsageStat>> getTodayUsage() async {
    if (!isSupported) return const [];
    final values = await _channel.invokeListMethod<Object?>('getTodayUsage');
    return (values ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(AppUsageStat.fromMap)
        .toList();
  }
}
