import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:developer' as developer;

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {}

class NotificationHandler {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static NotificationDetails platformChannelSpecifics =
      NotificationDetails(iOS: iOSPlatformChannelSpecifics);

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    tz.initializeTimeZones();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  static IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(
          presentAlert:
              true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          presentBadge:
              true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          presentSound:
              true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
          sound:
              null, // Specifics the file path to play (only from iOS 10 onwards)
          badgeNumber: 10, // The application's icon badge number
          attachments: null,
          subtitle: null, //Secondary description  (only from iOS 10 onwards)
          threadIdentifier: null);

  showNotification() async {
    await flutterLocalNotificationsPlugin.show(
        12345,
        "A Notification From My Application",
        "This notification was sent using Flutter Local Notifcations Package",
        platformChannelSpecifics,
        payload: 'data');
  }

  shedule() async {
    await flutterLocalNotificationsPlugin.periodicallyShow(
      12345,
      "A Notification From My App",
      "This notification is brought to you by Local Notifcations Package",
      RepeatInterval.everyMinute,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "CHANNEL_ID",
          "CHANNEL_NAME",
          "CHANNEL_DESCRIPTION",
        ),
        iOS: IOSNotificationDetails(
            presentAlert:
                true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
            presentBadge:
                true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
            presentSound:
                true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
            sound:
                null, // Specifics the file path to play (only from iOS 10 onwards)
            badgeNumber: 10, // The application's icon badge number
            attachments: null,
            subtitle: null, //Secondary description  (only from iOS 10 onwards)
            threadIdentifier: null),
      ),
      androidAllowWhileIdle: true,
    );
  }

  Future selectNotification(String payload) async {
    //Handle notification tapped logic here
    developer.log("Tap");
  }
}
