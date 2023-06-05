import 'package:flutter/material.dart';

import 'package:google_auth/functions/sql_client.dart';
import 'package:google_auth/routes/beranda/dashboard.dart';
import 'package:google_auth/routes/keluhan/dashboard.dart';
import 'package:google_auth/widgets/bottomNavigationBar.dart';
import 'package:google_auth/widgets/profile.dart';
import '../functions/sqlite.dart';
import '../strings/user.dart';
import '../widgets/image.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({super.key});

  @override
  State<DashboardRoute> createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
  int currentPage = 4;
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: currentPage);
    logUser();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void changePage(int page) {
    setState(() {
      currentPage = page;     
    });
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
      SQL.insert(item: item, api: 'ousr');
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
        flexibleSpace: FlexibleSpaceBar(
          background: ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            child: Container(
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.65),
                    Theme.of(context).colorScheme.primary,
                  ]
                )
              ),
              child: Image.asset('assets/dashboard_header.png', fit: BoxFit.cover)
            )
          )
        ),
        title: Row(
          children: [
            IconButton(
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              onPressed: () {}, icon: const Icon(Icons.search), color: Theme.of(context).colorScheme.surface
            ),
            const SizedBox(width: 4),
            Text('Hi, ${currentUser['user_name']}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.surface)
            ),
          ],
        ),
        titleSpacing: 12,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none), color: Theme.of(context).colorScheme.surface),
          const SizedBox(width: 6),
          const ProfileMenu(),
          const SizedBox(width: 12),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) => setState(() => changePage(value)),
        children: [
          Container(),
          const KeluhanRoute(),
          Container(),
          Container(),
          const BerandaRoute()
        ]
      ),
      bottomNavigationBar: BottomNavigation(currentPage: currentPage, pageController: _pageController, changePage: changePage)
    );
  }
}
