import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'package:google_auth/routes/belanja/dashboard.dart';
import 'package:google_auth/routes/beranda/dashboard.dart';
import 'package:google_auth/routes/keluhan/dashboard.dart';
import 'package:google_auth/widgets/bottomNavigationBar.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/profile.dart';
import 'package:google_auth/widgets/snackbar.dart';
import '../functions/sqlite.dart';
import '../strings/user.dart';
import '../widgets/image.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({super.key, this.currentPage});

  final int? currentPage;

  @override
  State<DashboardRoute> createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
  late int currentPage;
  late PageController _pageController;
  final AsyncMemoizer _logUserMemozer = AsyncMemoizer();

  @override
  void initState() {
    currentPage = widget.currentPage ?? 0;
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

  Future<void> logUser() async {
    _logUserMemozer.runOnce(() {
      UserLog userLog = UserLog(
        id_olog: null, 
        date_time: DateNowSQL(),
        form_sender: currentUser['login_type'],
        remarks: currentUser['user_name'], 
        source: currentUser['user_email'],
        id_ousr: currentUser['id_ousr'].toString()
      );
      UserLog.insert(userLog).onError((error, stackTrace) {
        showSnackBar(context, snackBarError(context: context, content: error.toString()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)
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
          CartWidget(color: Theme.of(context).colorScheme.surface),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none), color: Theme.of(context).colorScheme.surface, 
            style: const ButtonStyle(visualDensity: VisualDensity.compact)
          ),
          const SizedBox(width: 6),
          const ProfileMenu(),
          const SizedBox(width: 12),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) => setState(() => changePage(value)),
        children: [
          const BerandaRoute(),
          Container(),
          const BelanjaRoute(),
          const KeluhanRoute(),
          Container(),
        ]
      ),
      bottomNavigationBar: BottomNavigation(currentPage: currentPage, pageController: _pageController, changePage: changePage)
    );
  }
}
