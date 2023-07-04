import 'package:flutter/material.dart';
import 'package:google_auth/functions/permission.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/listtile.dart';

class NotificationMenu extends StatelessWidget {
  const NotificationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.star),
              SizedBox(
                width: 10,
              ),
              Text("Get The App")
            ],
          ),
        ),
        const PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.chrome_reader_mode),
              SizedBox(
                width: 10,
              ),
              Text("About")
            ],
          ),
        ),
      ],
      elevation: 2,
      child: const Icon(Icons.notifications_none, color: Colors.white),
    );
  }
}

class NotificationPermissionWidget extends StatefulWidget{
  const NotificationPermissionWidget({super.key, required this.title});

  final String title;

  @override
  State<NotificationPermissionWidget> createState() => _NotificationPermissionWidgetState();
}

class _NotificationPermissionWidgetState extends State<NotificationPermissionWidget> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return ListTileToast(
      leading: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Icon(Icons.info, size: 18, color: Theme.of(context).colorScheme.primary),
      ),
      title: widget.title,
      subtitle: 'Untuk mendapatkan notifikasi kami perlu persetujuan dari Anda.',
      action: ElevatedButton.icon(
        onPressed: () {
          if (checked == false) {
            PermissionService.requestNotification().whenComplete(() => checked = true);
          } else {
            PermissionService.openSettings();
          }
        },
        style: Styles.buttonFlatSmall(context: context, borderRadius: BorderRadius.circular(4)),
        icon: const Icon(Icons.lock_open),
        label: Text('Beri Akses', style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10,
          color: Theme.of(context).colorScheme.surface
        ))
      ),
    );
  }
}

class NotificationSmallWidget extends StatelessWidget {
  const NotificationSmallWidget({super.key, required this.message, this.icon, this.color, this.padding});

  final String message;
  final IconData? icon;
  final Color? color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8),
      color: color?.withOpacity(0.5) ?? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
      child: Row(
        children: [
          Icon(icon ?? Icons.info, size: 16, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color ?? Theme.of(context).colorScheme.primary,
            height: 0,
            letterSpacing: 0
          )),
        ],
      ),
    );
  }
}