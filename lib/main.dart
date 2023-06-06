import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

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
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.1),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Customer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Customer'),
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
