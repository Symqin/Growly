import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // =================================================
  // INIT (PANGGIL DI main.dart)
  // =================================================
  static Future<void> init() async {
    // Init timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // 🔔 ICON NOTIFIKASI KHUSUS
    const androidInit = AndroidInitializationSettings('ic_notification');

    const settings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl == null) return;

    // 🔥 CHANNEL (WAJIB UNTUK ANDROID)
    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        'habit_exact',
        'Daily Habit Reminder',
        description: 'Daily habit reminder (exact)',
        importance: Importance.high,
      ),
    );

    // Android 13+
    await androidImpl.requestNotificationsPermission();
  }

  // =================================================
  // CHECK EXACT ALARM PERMISSION (ANDROID 12+)
  // =================================================
  static Future<bool> ensureExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    }

    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  // =================================================
  // OPEN SYSTEM SETTINGS (EXACT ALARM)
  // =================================================
  static Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    await openAppSettings();
  }

  // =================================================
  // SCHEDULE DAILY EXACT NOTIFICATION
  // =================================================
  static Future<void> scheduleDailyExact({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Kalau waktu sudah lewat → besok
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint('NOW       : $now');
    debugPrint('SCHEDULED : $scheduled');

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_exact',
          'Daily Habit Reminder',
          channelDescription: 'Daily habit reminder (exact)',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification', // 🔥 ICON NOTIF
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // =================================================
  // CANCEL
  // =================================================
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
