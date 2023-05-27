import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_auth/functions/sqlite.dart';

import 'functions/google_signin.dart';
import 'widgets/button.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Google Auth'),
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

  User? user;

  void pushLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyDashboard(user: user!, loginWith: 'Google',)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.surface)),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder(
          future: Authentication.initializeFirebase(context: context, pushLogin: pushLogin),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error initializing Firebase');
            } else if (snapshot.connectionState == ConnectionState.done) {
              return GoogleSignInButton(
                onPressed: () async {
                  user = await Authentication.signInWithGoogle(context: context, pushLogin: pushLogin);
                }
              );
            }

            return CircularProgressIndicator(color: Theme.of(context).colorScheme.primary);
          },
        ),
      ),
    );
  }
}

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key, required this.user, required this.loginWith});

  final User user;
  final String loginWith;

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {

  void pushLogout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Logout Success')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.user.displayName!, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.surface)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.user.photoURL != null
                  ? ClipOval(
                      child: Material(
                        child: Image.network(
                          widget.user.photoURL!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    )
                  : const ClipOval(
                      child: Material(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    widget.user.displayName!,
                    style: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                  Text(
                    widget.user.email!,
                    style: const TextStyle(
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () async {
                      await Authentication.signOut(context: context, pushLogout: pushLogout);
                    }, 
                    style: ButtonStyle(
                      side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                    child: const Text('Keluar')
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  var user = UserLog(
                    id_olog: -1, 
                    date_time: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                    from_sender: widget.loginWith, 
                    remarks: widget.user.displayName!, 
                    source: widget.user.email!
                  );
                  UserLog.insert(user);

                  print(user);
                },
                child: const Text('Insert')
              )
            ],
          ),
        ),
      ),
    );
  }
}
