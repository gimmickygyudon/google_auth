import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/functions/mysql_client.dart';
import 'package:google_auth/widgets/image.dart';
import 'package:intl/intl.dart';

import '../functions/authentication.dart';
import '../functions/sqlite.dart';
import '../routes/login_page.dart';
import '../widgets/snackbar.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({super.key, this.user, required this.loginWith, this.source});

  final User? user;
  final String loginWith;
  final Map? source;

  @override
  State<DashboardRoute> createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
  late String logDateStamp, logDateSqlStamp;
  late Map<String, dynamic> currentUser;

  @override
  void initState() {
    logDateStamp = DateFormat('kk:mm y/M/d').format(DateTime.now());
    logDateSqlStamp = DateFormat('y-MM-d H:m:ss').format(DateTime.now());
    
    if (widget.source == null) {
      currentUser = {
        'email': widget.user?.email,
        'name': widget.user?.displayName,
        'photo': widget.user?.photoURL,
        'loginWith': 'Google',
        'date': logDateSqlStamp
      };
    } else {
      currentUser = {
        'email': widget.source?['user_email'],
        'name': widget.source?['user_name'],
        'loginWith': widget.loginWith,
        'date': logDateSqlStamp
      };
    }
    UserLog.log_user(currentUser['email'], currentUser);
    super.initState();
  }

  void pushLogout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginRoute()));
  }

  // TODO: MOVE THIS SOMEWHERE
  void insertOLOG() {
    UserLog.retrieve(currentUser['email']).then((value) async {
      MySQL.retrieve(value.last.source, 'olog').then((value) {
        Map<String, dynamic> item = {
          'id_olog': value['id_olog'] + 1,
          'date_time': DateFormat('y-MM-d H:m:ss').format(DateTime.now()),
          'form_sender': value['form_sender'],
          'remarks': value['remarks'],
          'source': value['source']
        };
        MySQL.insert(item, 'olog');
      });
    }); 
  }

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
      MySQL.insert(item, 'ousr'); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: PhotoProfile(photo: currentUser['photo'], size: 58, color: Theme.of(context).colorScheme.surface),
              currentAccountPictureSize: const Size(58, 58),
              accountName: Text(currentUser['name'], style: TextStyle(color: Theme.of(context).colorScheme.surface)),
              accountEmail: Text(currentUser['email'], style: TextStyle(color: Theme.of(context).colorScheme.surfaceVariant,fontSize: 12))
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
              child: Text(currentUser['name'], style: TextStyle(color: Theme.of(context).colorScheme.surface))
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
                  leading: PhotoProfile(photo: currentUser['photo'], size: 36),
                  title: Text(currentUser['name'], style: const TextStyle(letterSpacing: 0.5)),
                  subtitle: Text(currentUser['email'],
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
                  // TODO: remove later
                  pushLogout();
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
            child: PhotoProfile(photo: currentUser['photo'], size: 32, color: Theme.of(context).colorScheme.surface),
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
                      // UserLog.retrieve(currentUser['email']).then((value) {
                      //   (MySQL.retrieve(value.last.source)).then((value) => print(value));
                      // });
                      MySQL.retrieve(currentUser['email'], 'ousr').then((value) => print(value));
                    },
                    child: const Text('Retrieve')
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      insertOUSR();
                    },
                    child: const Text('Insert')
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      UserLog.retrieve(currentUser['email']).then((value) {
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