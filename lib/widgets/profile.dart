import 'package:flutter/material.dart';

import '../functions/authentication.dart';
import '../functions/push.dart';
import '../strings/user.dart';
import 'image.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key, required this.source});

  final Map? source;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Padding(
              padding: EdgeInsets.all(source?['photo_url'] != null ? 2 : 0),
              child: source?['photo_url'] != null 
              ? CircleAvatar(
                backgroundImage: NetworkImage(source?['photo_url']),
                radius: 32
              ) 
              : Icon(Icons.account_circle, size: 80, color: Theme.of(context).colorScheme.secondary),
            ),
            if (source?['photo_url'] != null) Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:BorderRadius.circular(25.7)
              ),
              child: const CircleAvatar(
                backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2008px-Google_%22G%22_Logo.svg.png'),
                radius: 10,
              ),
            )
          ],
        ),
        if (source?['photo_url'] != null) const SizedBox(height: 12),
        Text(source?['user_name'], style: Theme.of(context).textTheme.titleMedium),
        Text(source?['user_email'], style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) => [
        PopupMenuItem(
          height: 0,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: PhotoProfile(photo: currentUser['photo'], size: 40),
            title: Text(currentUser['user_name']),
            titleTextStyle: Theme.of(context).textTheme.titleSmall,
            subtitle: Text(currentUser['user_email']),
            subtitleTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 11,
            ),
            trailing: const Icon(Icons.settings),
          )
        ),
        const PopupMenuItem(enabled: false, height: 0, child: PopupMenuDivider()),
        PopupMenuItem(
          onTap: () {
            Authentication.signOut().whenComplete(() => pushStart(context));
          },
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.only(left: 6),
            leading: Icon(Icons.logout),
            title: Text('Logout  /  Keluar')
          )
        ),
        PopupMenuItem(
          enabled: false,
          height: 28,
          child: Text('v1.0.0+1 • Logged in $DateNow', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
        )
      ],
      child: PhotoProfile(photo: currentUser['photo_url'], size: 32, color: Theme.of(context).colorScheme.surface),
    );
  }
}
