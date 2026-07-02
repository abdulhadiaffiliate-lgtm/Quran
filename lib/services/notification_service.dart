import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../models/prayer_times.dart';
import 'app_settings.dart';

/// Handles scheduling local notifications for daily prayers and two daily
/// reminders (read Quran / listen to dua). Key fixes in this version:
///
///  - cancelAll() no longer used before scheduling prayers — reminders are
///    cancelled and rescheduled separately so they survive prayer updates.
///  - matchDateTimeComponents removed from prayer notifications so each
///    prayer fires ONCE, not on an infinite daily repeat.
///  - Daily reminders scheduled with matchDateTimeComponents.time so they
///    DO repeat every day at the same time.
///  - Battery optimisation exemption requested on first launch.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Notification ID ranges — keep separate so cancellations don't collide.
  static const int _prayerIdBase = 100;  // 100-104 (5 prayers)
  static const int _reminderIdBase = 200; // 200-201 (2 daily reminders)

  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(_locationForCurrentOffset());
    } catch (_) {}

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static tz.Location _locationForCurrentOffset() {
    final deviceOffset = DateTime.now().timeZoneOffset;
    final now = DateTime.now().toUtc();
    // Prefer the first location that exactly matches, prioritising common
    // Asia locations for Pakistan/South Asia to reduce mis-matches.
    const preferred = [
      'Asia/Karachi',
      'Asia/Kolkata',
      'Asia/Dhaka',
      'Asia/Kabul',
    ];
    for (final name in preferred) {
      try {
        final loc = tz.getLocation(name);
        final tzNow = tz.TZDateTime.from(now, loc);
        if (tzNow.timeZoneOffset == deviceOffset) return loc;
      } catch (_) {}
    }
    for (final loc in tz.timeZoneDatabase.locations.values) {
      final tzNow = tz.TZDateTime.from(now, loc);
      if (tzNow.timeZoneOffset == deviceOffset) return loc;
    }
    return tz.getLocation('UTC');
  }

  /// Requests notification + exact alarm permissions (Android 13+).
  static Future<void> requestPermissions() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showTestNotification() async {
    await init();
    final style = await AppSettings.getNotifyStyle();
    final playSound = style != NotifyStyle.silent;
    await _plugin.show(
      1,
      'SalahSync test',
      'If you can see this, notifications are working in shaa Allah.',
      _buildDetails(style: style, playSound: playSound, isReminder: false),
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Schedules today's 5 prayer notifications. Past prayers are skipped
  /// (not rescheduled for tomorrow — prayers rescheduled on next app open).
  /// Does NOT cancel daily reminders.
  static Future<void> schedulePrayers(PrayerTimes times) async {
    await init();
    // Only cancel prayer notification IDs, not daily reminders.
    for (int i = _prayerIdBase; i < _prayerIdBase + 5; i++) {
      await _plugin.cancel(i);
    }

    final style = await AppSettings.getNotifyStyle();
    if (style == NotifyStyle.silent) return;

    final prayers = <String, DateTime>{
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };

    int id = _prayerIdBase;
    final now = DateTime.now();
    for (final entry in prayers.entries) {
      final when = entry.value;
      // Skip prayers that have already passed today.
      if (when.isBefore(now)) {
        id++;
        continue;
      }
      await _schedulePrayerOnce(
        id: id++,
        prayerName: entry.key,
        when: when,
        style: style,
      );
    }
  }

  /// Schedules 2 daily reminders that repeat every day:
  ///  - Morning (after Fajr): read a page of Quran
  ///  - Evening (after Maghrib): listen to dua of the day
  static Future<void> scheduleDailyReminders() async {
    await init();
    // Cancel and re-schedule so times update if user changes settings.
    for (int i = _reminderIdBase; i < _reminderIdBase + 2; i++) {
      await _plugin.cancel(i);
    }

    final now = DateTime.now();

    // Reminder 1 — 8:00 AM (after Fajr, a good time to read Quran)
    var morning = DateTime(now.year, now.month, now.day, 8, 0);
    if (morning.isBefore(now)) {
      morning = morning.add(const Duration(days: 1));
    }

    // Reminder 2 — 7:30 PM (after Maghrib, a good time for evening dua)
    var evening = DateTime(now.year, now.month, now.day, 19, 30);
    if (evening.isBefore(now)) {
      evening = evening.add(const Duration(days: 1));
    }

    await _scheduleDailyRepeat(
      id: _reminderIdBase,
      title: 'Time to read Quran',
      body: 'Even a page a day keeps the heart connected. Open SalahSync.',
      when: morning,
    );

    await _scheduleDailyRepeat(
      id: _reminderIdBase + 1,
      title: 'Dua of the day',
      body: 'Take a moment for your evening dua and remembrance.',
      when: evening,
    );
  }

  static Future<void> _schedulePrayerOnce({
    required int id,
    required String prayerName,
    required DateTime when,
    required NotifyStyle style,
  }) async {
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id,
      'Time for $prayerName',
      'It\'s time to pray $prayerName. May Allah accept it from you.',
      tzWhen,
      _buildDetails(style: style, playSound: true, isReminder: false),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // No matchDateTimeComponents — fires ONCE, not infinitely repeating.
    );
  }

  static Future<void> _scheduleDailyRepeat({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzWhen,
      _buildDetails(
          style: NotifyStyle.notification,
          playSound: true,
          isReminder: true),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents.time makes this repeat daily at the same time.
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static NotificationDetails _buildDetails({
    required NotifyStyle style,
    required bool playSound,
    required bool isReminder,
  }) {
    final AndroidNotificationDetails androidDetails;

    if (!isReminder && style == NotifyStyle.azan) {
      androidDetails = const AndroidNotificationDetails(
        'prayer_azan_v2',
        'Prayer Azan',
        channelDescription: 'Plays the adhan at prayer time',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
      );
    } else if (isReminder) {
      androidDetails = const AndroidNotificationDetails(
        'daily_reminders_v1',
        'Daily Reminders',
        channelDescription: 'Daily Quran and dua reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        'prayer_default_v2',
        'Prayer Reminders',
        channelDescription: 'Reminds you when each prayer time arrives',
        importance: playSound ? Importance.max : Importance.low,
        priority: playSound ? Priority.high : Priority.low,
        playSound: playSound,
      );
    }

    return NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: playSound,
        sound: (!isReminder && style == NotifyStyle.azan) ? 'adhan.wav' : null,
      ),
    );
  }
}
