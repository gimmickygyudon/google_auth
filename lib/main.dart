import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_auth/styles/scroll.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'functions/notification.dart';
import 'functions/push.dart';
import 'routes/start_page.dart';
import 'functions/authentication.dart';
import 'styles/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  return runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(),
    child: const MyApp(),
  ));
}

Future backgroundHandler(RemoteMessage msg) async {}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: true,
          textScaleFactor: 1.0
        ),
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Customer',
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            themeMode: theme.getTheme(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
             Locale('id'),
           ],
            builder: (context, child) {
              return ResponsiveBreakpoints.builder(
                child: Builder(
                  builder: (context) {
                    return ScrollConfiguration(
                      behavior: const ScrollBehaviorModified(),
                      child: Container(
                        color: Theme.of(context).colorScheme.background,
                        child: ResponsiveScaledBox(
                          autoCalculateMediaQueryData: true,
                          width: ResponsiveValue<double>(
                            context,
                            conditionalValues: [
                              Condition.equals(name: MOBILE, value: 450),
                            ],
                          ).value,
                          child: child!
                        )
                      ),
                    );
                  }
                ),
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 850, name: TABLET),
                  const Breakpoint(start: 851, end: double.infinity, name: DESKTOP),
                ],
                breakpointsLandscape: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
                ],
              );
            },
            home: const MyHomePage(title: 'Customer'),
          ),
        ),
      ),
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
