import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const String _dailyChannelId = "daily_channel";

  Future<void> init() async {
    // ================= Android Settings =================
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      _dailyChannelId,
      'Daily Notifications',
      description: 'إشعارات التذكير اليومي',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(dailyChannel);

    // ================= iOS Settings =================
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // طلب صلاحيات iOS إضافية
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    debugPrint("✅ NotificationService initialized");
  }

  /// جدول إشعار يومي على أي إصدار أندرويد من 6 إلى 13
  Future<void> scheduleDaily(
      TimeOfDay time, {
        String title = "تذكير يومي",
        String body = "صباح الخير عزيزي! لا تنس تسجيل مصروفاتك اليوم ✨",
      }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // إذا الوقت قبل الآن → أضف يوم
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _dailyChannelId,
        'Daily Notifications',
        channelDescription: 'إشعارات التذكير اليومي',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      1001,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint("⏰ Daily notification scheduled at $scheduled");
  }

  Future<void> cancelDaily() async {
    await _notifications.cancel(1001);
    debugPrint("🗑️ Daily notification canceled");
  }
}

