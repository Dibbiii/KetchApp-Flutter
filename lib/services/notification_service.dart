// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  static Future<void> schedulePomodoroNotification(String title, DateTime start) async {
    final scheduledTime = tz.TZDateTime.from(start.subtract(const Duration(minutes: 15)), tz.local);
    // Notifica immediata
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Promemoria Pomodoro',
      'Hai appena creato: $title',
      const NotificationDetails(
        android: AndroidNotificationDetails('pomodoro_channel', 'Pomodori'),
        iOS: DarwinNotificationDetails(),
      ),
    );
    // Notifica 15 minuti prima
    if (scheduledTime.isAfter(DateTime.now())) {
      try {
        await _notificationsPlugin.zonedSchedule(
          scheduledTime.millisecondsSinceEpoch ~/ 1000,
          'Promemoria Pomodoro',
          'Tra 15 minuti inizia: $title',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails('pomodoro_channel', 'Pomodori'),
            iOS: DarwinNotificationDetails(),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
        print('ANotification scheduled for $title at $scheduledTime');
      } on PlatformException catch (e) {
        if (e.code == 'exact_alarms_not_permitted') {
          await _notificationsPlugin.show(
            DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
            'Promemoria Pomodoro',
            'Tra 15 minuti inizia: $title (notifica inviata subito, permesso non concesso)',
            const NotificationDetails(
              android: AndroidNotificationDetails('pomodoro_channel', 'Pomodori'),
              iOS: DarwinNotificationDetails(),
            ),
          );
          print('Notifica inviata subito per mancanza permesso exact alarm');
        } else {
          print('Errore nella programmazione della notifica: $e');
          rethrow;
        }
      } catch (e) {
        print('Errore nella programmazione della notifica: $e');
        rethrow;
      }
    }
  }
}
