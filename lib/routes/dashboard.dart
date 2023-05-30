import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/mysql_client.dart';
import 'package:intl/intl.dart';

import '../functions/google_signin.dart';
import '../functions/sqlite.dart';
import '../routes/login_page.dart';
import '../widgets/snackbar.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({super.key, required this.user, required this.loginWith});

  final User user;
  final String loginWith;

  @override
  State<DashboardRoute> createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
  late String logDateStamp;

  @override
  void initState() {
    logDateStamp = DateFormat('kk:mm y/M/d').format(DateTime.now());

    Map<String, dynamic> currentUser = {
      'email': widget.user.email,
      'name': widget.user.displayName,
      'loginWith': 'Google',
      'date': DateFormat('y-MM-d H:m:ss').format(DateTime.now())
    };
    UserLog.log_user(widget.user.email!, currentUser);
    super.initState();
  }

  void pushLogout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginRoute()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(widget.user.photoURL!)),
              currentAccountPictureSize: const Size(58, 58),
              accountName: Text(widget.user.displayName!, style: TextStyle(color: Theme.of(context).colorScheme.surface)),
              accountEmail: Text(widget.user.email!, style: TextStyle(color: Theme.of(context).colorScheme.surfaceVariant,fontSize: 12))
            ),
          ],
        ),
      ),
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12)
          )
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.menu, color: Theme.of(context).colorScheme.surface),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          }
        ),
        title: Builder(
          builder: (context) {
            return TextButton(
              style: const ButtonStyle(visualDensity: VisualDensity(vertical: -4, horizontal: -4)),
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: Text(widget.user.displayName!, style: TextStyle(color: Theme.of(context).colorScheme.surface))
            );
          }
        ),
        leadingWidth: 28,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          PopupMenuButton(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.user.photoURL!,
                    ),
                  ),
                  title: Text(widget.user.displayName!, style: const TextStyle(letterSpacing: 0.5)),
                  subtitle: Text(widget.user.email!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              ),
              const PopupMenuItem(enabled: false, height: 0, child: PopupMenuDivider()),
              PopupMenuItem(
                onTap: () async {
                  hideSnackBar(context);
                  await Authentication.signOut(context: context, pushLogout: pushLogout);
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
                child: Text('v1.0.0+1 • Logged in $logDateStamp', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400)),
              )
            ],
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                widget.user.photoURL!,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      UserLog.retrieve(widget.user.email).then((value) {
                        (MySQL.retrieve(value.last.source)).then((value) => print(value));
                      });
                    },
                    child: const Text('Retrieve')
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      UserLog.retrieve(widget.user.email).then((value) async {
                        MySQL.retrieve(value.last.source).then((value) {
                          Map<String, dynamic> item = {
                            'id_olog': value['id_olog'] + 1,
                            'date_time': DateFormat('y-MM-d H:m:ss').format(DateTime.now()),
                            'form_sender': value['form_sender'],
                            'remarks': value['remarks'],
                            'source': value['source']
                          };
                          MySQL.insert(item);
                        });
                      });
                    },
                    child: const Text('Insert')
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      UserLog.retrieve(widget.user.email).then((value) {
                        Map<String, dynamic> item = {
                          'id_olog': value.last.id_olog,
                          'date_time': value.last.date_time,
                          'form_sender': value.last.form_sender,
                          'remarks': value.last.remarks,
                          'source': value.last.source
                        };
                      });
                    },
                    child: const Text('Update')
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}