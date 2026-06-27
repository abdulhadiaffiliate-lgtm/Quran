import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/prayer_times.dart';
import 'app_settings.dart';

/// Handles scheduling local notifications for each daily prayer, honoring
/// the user's chosen notification style (Azan / Notification / Silent).
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Must be called once at app startup before scheduling.
  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    // Use the device's actual IANA timezone for accurate scheduling.
    try {
      final String localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone));
    } catch (_) {
      // Fallback: default location. Scheduling still uses local DateTime.
    }

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Requests notification permission (Android 13+ / iOS).
  static Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Shows an immediate test notification so the user can confirm
  /// notifications are working and styled per their preference.
  static Future<void> showTestNotification() async {
    await init();
    final style = await AppSettings.getNotifyStyle();
    final bool playSound = style != NotifyStyle.silent;

    AndroidNotificationDetails androidDetails;
    if (style == NotifyStyle.azan) {
      androidDetails = const AndroidNotificationDetails(
        'prayer_azan',
        'Prayer Azan',
        channelDescription: 'Plays the adhan at prayer time',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        'prayer_default',
        'Prayer Reminders',
        channelDescription: 'Reminds you when each prayer time arrives',
        importance: style == NotifyStyle.silent
            ? Importance.low
            : Importance.max,
        priority:
            style == NotifyStyle.silent ? Priority.low : Priority.high,
        playSound: playSound,
      );
    }

    final details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentSound: playSound),
    );

    await _plugin.show(
      1,
      'SalahSync test',
      'If you can see this, notifications are working in shaa Allah.',
      details,
    );
  }

  /// Cancels all scheduled prayer notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Schedules notifications for today's five prayers based on [times] and
  /// the user's notification style. Past prayers for today are skipped.
  static Future<void> schedulePrayers(PrayerTimes times) async {
    await init();
    await cancelAll();

    final style = await AppSettings.getNotifyStyle();
    if (style == NotifyStyle.silent) {
      // Still schedule, but as a low-importance, soundless notification.
    }

    final prayers = <String, DateTime>{
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };

    int id = 100;
    final now = DateTime.now();
    for (final entry in prayers.entries) {
      var when = entry.value;
      // If the prayer time already passed today, schedule for tomorrow.
      if (when.isBefore(now)) {
        when = when.add(const Duration(days: 1));
      }
      await _scheduleOne(
        id: id++,
        prayerName: entry.key,
        when: when,
        style: style,
      );
    }
  }

  static Future<void> _scheduleOne({
    required int id,
    required String prayerName,
    required DateTime when,
    required NotifyStyle style,
  }) async {
    final tzWhen = tz.TZDateTime.from(when, tz.local);

    final bool playSound = style != NotifyStyle.silent;
    final Importance importance = style == NotifyStyle.silent
        ? Importance.low
        : Importance.max;
    final Priority priority =
        style == NotifyStyle.silent ? Priority.low : Priority.high;

    // For the Azan style we reference a custom raw sound resource named
    // 'adhan'. The user must add android/app/src/main/res/raw/adhan.mp3.
    AndroidNotificationDetails androidDetails;
    if (style == NotifyStyle.azan) {
      androidDetails = AndroidNotificationDetails(
        'prayer_azan',
        'Prayer Azan',
        channelDescription: 'Plays the adhan at prayer time',
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        'prayer_default',
        'Prayer Reminders',
        channelDescription: 'Reminds you when each prayer time arrives',
        importance: importance,
        priority: priority,
        playSound: playSound,
      );
    }

    final iosDetails = DarwinNotificationDetails(
      presentSound: playSound,
      sound: style == NotifyStyle.azan ? 'adhan.aiff' : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      'Time for $prayerName',
      'It\'s time to pray $prayerName. May Allah accept it from you.',
      tzWhen,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
