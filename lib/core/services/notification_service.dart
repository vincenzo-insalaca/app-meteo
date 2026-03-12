import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> showSevereWeatherAlert({
    required String cityName,
    required String condition,
  });
  Future<void> scheduleDailySummary({
    required String cityName,
    required int temperature,
    required String condition,
  });
}

class NotificationServiceImpl implements NotificationService {
  static const _channelId = 'meteo_channel';
  static const _channelName = 'Notifiche meteo';
  static const _severeId = 1;
  static const _summaryId = 2;

  final FlutterLocalNotificationsPlugin _plugin;

  NotificationServiceImpl()
      : _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Request Android 13+ notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> showSevereWeatherAlert({
    required String cityName,
    required String condition,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      _severeId,
      'Allerta meteo',
      'Attenzione: $condition previsto a $cityName',
      details,
    );
  }

  @override
  Future<void> scheduleDailySummary({
    required String cityName,
    required int temperature,
    required String condition,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final tzPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (tzPlugin == null) return;

    // Schedule for 08:00 daily using inexact alarm (battery friendly)
    await _plugin.periodicallyShow(
      _summaryId,
      'Previsioni del giorno',
      '$cityName: $temperature°, $condition',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
