import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
    initFirebaseApp();
    super.initState();
  }

  void initFirebaseApp() async {
    firebaseApp = await Authentication.initializeFirebase(context: context).whenComplete(() {
      if (FirebaseAuth.instance.currentUser == null) setState(() => _isLoggedIn = false);

      // TODO: disable auto login for debug
      setState(() => _isLoggedIn = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: _isLoggedIn ? Center(child: Image.asset('assets/temp_image.png')) : const StartPageRoute()
        ),
      ),
    );
  }
}
