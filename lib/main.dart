import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:responsive_framework/utils/responsive_utils.dart';

import 'functions/push.dart';
import 'routes/start_page.dart';
import 'functions/authentication.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      builder: (context, child) {
        // print('height: ${MediaQuery.of(context).size.height}');
        // print('width: ${MediaQuery.of(context).size.width}');
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.3),
          child: ResponsiveWrapper.builder(
            child,
            maxWidth: 600,
            minWidth: 200,
            maxWidthLandscape: 4000,
            minWidthLandscape: 600,
            breakpointsLandscape: [
              const ResponsiveBreakpoint.resize(400, name: MOBILE, scaleFactor: 0.75),
              const ResponsiveBreakpoint.resize(600, name: TABLET, scaleFactor: 0.75),
              const ResponsiveBreakpoint.resize(1024, name: DESKTOP),
              const ResponsiveBreakpoint.resize(1600, name: '4K'),
            ],
            defaultScale: true,
            breakpoints: [
              const ResponsiveBreakpoint.resize(200, name: MOBILE, scaleFactor: 0.9),
              const ResponsiveBreakpoint.resize(400, name: TABLET, scaleFactor: 0.95),
              const ResponsiveBreakpoint.resize(1024, name: DESKTOP),
              const ResponsiveBreakpoint.resize(1600, name: '4K'),
            ]
          ),
        );
      },
      home: const MyHomePage(title: 'Customer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseApp firebaseApp;
  bool _isLoggedIn = true;

  @override
  void initState() {
    initializeDateFormatting();
    initUser();
    super.initState();
  }

  void initUser() async {
    Authentication.initializeFirebase().whenComplete(() {
      // if (FirebaseAuth.instance.currentUser == null) setState(() => _isLoggedIn = false);
      setState(() => _isLoggedIn = false);
    });

    Authentication.initializeUser().then((user) async {
      if (user != null) {
        // TODO: problem later when user already deleted.
        Authentication.signIn(user as Map<String, dynamic>).whenComplete(() => pushDashboard(context));
      } 
      setState(() => _isLoggedIn = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: _isLoggedIn 
      ? Scaffold(backgroundColor: Theme.of(context).colorScheme.background, body: Center(child: Image.asset('assets/temp_image.png'))) 
      : const StartPageRoute()
    );
  }
}
