import 'package:flutter/material.dart';

import 'package:google_auth/functions/sql_client.dart';
import 'package:google_auth/routes/beranda/dashboard.dart';
import 'package:google_auth/widgets/bottomNavigationBar.dart';
import '../functions/authentication.dart';
import '../functions/push.dart';
import '../functions/sqlite.dart';
import '../strings/user.dart';
import '../widgets/image.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({super.key});

  @override
  State<DashboardRoute> createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
  final int currentPage = 0;

  @override
  void initState() {
    logUser();
    super.initState();
  }

  void logUser() {
     UserLog userLog = UserLog(
      id_olog: currentUser['id_ousr'], 
      date_time: DateNowSQL, 
      form_sender: currentUser['login_type'],
      remarks: currentUser['user_name'], 
      source: currentUser['user_email'],
    );
    UserLog.insert(userLog);
  }

  // TODO: USE THIS TO REGISTER TO SERVER
  void insertOUSR() {
    UserRegister.retrieve(currentUser['email']).then((value) async {
      Map<String, dynamic> item = {
        'id_ousr': (value.last.id_ousr! + 1),
        'login_type': value.last.login_type,
        'user_email': value.last.user_email,
        'user_name': value.last.user_name,
        'phone_number': value.last.phone_number,
        'user_password': value.last.user_password
      };
      SQL.insert(item, 'ousr');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: PhotoProfile(photo: currentUser['photo_url'], size: 58, color: Theme.of(context).colorScheme.surface),
              currentAccountPictureSize: const Size(58, 58),
              accountName: Text(currentUser['user_name'], style: TextStyle(color: Theme.of(context).colorScheme.surface)),
              accountEmail: Text(currentUser['user_email'], style: TextStyle(color: Theme.of(context).colorScheme.surfaceVariant,fontSize: 12))
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 8,
        shadowColor: Theme.of(context).shadowColor,
        automaticallyImplyLeading: false,
        toolbarHeight: kToolbarHeight + 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12)
          )
        ),
        title: Text(currentUser['user_name'], style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.surface)),
        leadingWidth: 28,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none), color: Theme.of(context).colorScheme.surface),
          PopupMenuButton(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: PhotoProfile(photo: currentUser['photo'], size: 36),
                  title: Text(currentUser['user_name'], style: const TextStyle(letterSpacing: 0.5)),
                  subtitle: Text(currentUser['user_email'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  trailing: const Icon(Icons.settings_outlined),
                )
              ),
              const PopupMenuItem(enabled: false, height: 0, child: PopupMenuDivider()),
              PopupMenuItem(
                onTap: () {
                  Authentication.signOut().whenComplete(() => pushLogout(context));
                },
                child: const ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
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
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: PageView(
        children: const [
          BerandaRoute()
        ]
      ),
      bottomNavigationBar: BottomNavigation(currentPage: currentPage)
    );
  }
}
