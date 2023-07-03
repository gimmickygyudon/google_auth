import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Permission checkNotification() {
    var notification = Permission.notification;

    return notification;
  }

  static Future<Permission> requestNotification() async {
    var notification = Permission.notification;

    if (await notification.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }

    return notification;
  }

  static Future<Permission> openSettings() async {
    var notification = Permission.notification;

    openAppSettings();

    return notification;
  }
}