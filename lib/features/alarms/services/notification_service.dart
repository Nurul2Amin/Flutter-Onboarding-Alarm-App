import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _alarmChannel =
      AndroidNotificationChannel(
    'alarm_channel',
    'Alarms',
    description: 'Channel for alarm notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('alarm1'),
  );

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    // Create channel (Android O+)
    final androidSpecific = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidSpecific?.createNotificationChannel(_alarmChannel);

    // ✅ Android 13+ permissions → handled separately
    // flutter_local_notifications removed `requestPermission()` for Android.
    // Use `permission_handler` package instead:
    // if (await Permission.notification.isDenied) {
    //   await Permission.notification.request();
    // }

    // ✅ iOS permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Schedules an alarm at [dateTime]. If the time has passed today, it schedules for tomorrow.
  static Future<void> scheduleAlarm(DateTime dateTime, int id) async {
    var target = dateTime;
    final now = DateTime.now();
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      'Alarm',
      'It’s time! ⏰',
      tz.TZDateTime.from(target, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Channel for alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('alarm1'),
          playSound: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          // sound: 'alarm1.mp3', // if you add a custom iOS sound
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAlarm(int id) async {
    await _plugin.cancel(id);
  }
}
