import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/permission.dart';

import 'package:google_auth/routes/belanja/dashboard.dart';
import 'package:google_auth/routes/beranda/dashboard.dart';
import 'package:google_auth/routes/gallery/dashboard.dart';
import 'package:google_auth/routes/keluhan/dashboard.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/navigationbar.dart';
import 'package:google_auth/widgets/cart.dart';
import 'package:google_auth/widgets/notification.dart';
import 'package:google_auth/widgets/profile.dart';
import 'package:google_auth/widgets/snackbar.dart';
import 'package:provider/provider.dart';
import '../functions/sqlite.dart';
import '../strings/user.dart';
import '../widgets/image.dart';

final AsyncMemoizer _logUserMemozer = AsyncMemoizer();
class DashboardRoute extends StatefulWidget {
  const DashboardRoute({super.key, this.currentPage});

  final int? currentPage;

  @override
  State<DashboardRoute> createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> {
  late int currentPage;
  late PageController _pageController;

  List<Widget?> routes = List.generate(6, (index) => null);
  late List<bool> routesLoading;

  @override
  void initState() {
    currentPage = widget.currentPage ?? 0;
    routesLoading = List.generate(routes.length, (index) => true);
    setRoutes();

    _pageController = PageController(initialPage: currentPage);

    Cart.getItems();
    logUser();
    PermissionService.requestNotification();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  setRoutes() {
    routes = [
      const BerandaRoute(),
      Container(),
      const BelanjaRoute(),
      GalleryRoute(isLoading: routesLoading[3]),
      const KeluhanRoute(),
      Container(),
    ];
  }

  void changePage(int page) {
    setState(() {
      if (page == 3) {
        borderCircular = 0;
        showtoolbar = false;
        toolbarHeight = 0;
      } else {
        borderCircular = 16;
        showtoolbar = true;
        toolbarHeight = kToolbarHeight;
      }
      currentPage = page;
      routesLoading.setAll(0, List.generate(routesLoading.length, (index) => true));
      routesLoading[currentPage] = false;
      setRoutes();
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

  double toolbarHeight = kToolbarHeight;
  bool showtoolbar = true;
  double borderCircular = 12;
  BorderRadius borderRadiusAppBar() {
    return BorderRadius.only(bottomLeft: Radius.circular(borderCircular), bottomRight: Radius.circular(borderCircular));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) => Scaffold(
        extendBody: showtoolbar == false ? true : false,
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
        appBar: showtoolbar ? PreferredSize(
          preferredSize: Size.fromHeight(toolbarHeight),
          child: AppBar(
            elevation: 8,
            shadowColor: theme.darkMode ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.5) : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
            automaticallyImplyLeading: false,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light
            ),
            shape: RoundedRectangleBorder(borderRadius: borderRadiusAppBar()),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: borderRadiusAppBar(),
                child: Container(
                  foregroundDecoration: BoxDecoration(
                    borderRadius: borderRadiusAppBar(),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.darkMode ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.9) : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.9),
                        theme.darkMode ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.primary,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Image.asset('assets/background02.png', fit: BoxFit.cover),
                  )
                )
              )
            ),
            title: Row(
              children: [
                IconButton(
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  onPressed: () {}, icon: const Icon(Icons.search), color: Colors.white
                ),
                const SizedBox(width: 4),
                Text('Hi, ${currentUser['user_name']}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white
                  )
                ),
              ],
            ),
            titleSpacing: 12,
            actions: const [
              CartWidget(color: Colors.white),
              SizedBox(width: 8),
              NotificationMenu(),
              SizedBox(width: 16),
              ProfileMenu(color: Colors.white),
              SizedBox(width: 12),
            ],
          ),
        ) : null,
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (value) => setState(() => changePage(value)),
          itemCount: 5,
          itemBuilder: (context, index) => routes[index]
        ),
        bottomNavigationBar: BottomNavigation(currentPage: currentPage, pageController: _pageController, changePage: changePage)
        // bottomNavigationBar: NavigationBarBottom(currentPage: currentPage, pageController: _pageController, changePage: changePage),
      ),
    );
  }
}