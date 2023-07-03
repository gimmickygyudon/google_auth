import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_notification');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      macOS: null
    );

   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}

class NotificationBody {
  static AndroidNotificationDetails androidPlatformChannelSpecifics =
    const AndroidNotificationDetails(
        'a',   //Required for Android 8.0 or after
        'a', //Required for Android 8.0 or after
        channelDescription: 'a', //Required for Android 8.0 or after
        icon: '@mipmap/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher_monochrome'),
        importance: Importance.max,
        priority: Priority.max
    );

  static NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  static showNotification({required int id, required String title, required String body}) async {
    await NotificationService.flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: 'data'
    );
  }
}