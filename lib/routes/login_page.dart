import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../functions/google_signin.dart';
import '../widgets/button.dart';
import '../widgets/snackbar.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key});

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  late bool loggingIn, visibility, isValidated;
  late TextEditingController _usernameController, _passwordController;

  @override
  void initState() {
    loggingIn = false;
    visibility = false;
    isValidated = false;

    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void validate() {
    if (_usernameController.text.trim().isNotEmpty && _passwordController.text.trim().isNotEmpty) {
      setState(() => isValidated = true);
    } else {
      setState(() => isValidated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          children: [
            Column(
              children: [
                Text('Hello Again', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 12),
                Text('Mulailah mengelola bisnis anda dengan aman dan cepat.', 
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.secondary), textAlign: TextAlign.center
                ),
              ],
            ),
            const SizedBox(height: 60),
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                  filled: true,
                  fillColor: Theme.of(context).hoverColor,
                  labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0, color: Theme.of(context).colorScheme.secondary),
                  floatingLabelStyle: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0, color: Theme.of(context).colorScheme.primary)
                )
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _usernameController,
                        onChanged: (value) => validate(),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          enabledBorder: _usernameController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
                        )
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        onChanged: (value) => validate(),
                        obscureText: visibility ? false : true,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          suffixIcon: Icon(visibility ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          enabledBorder: _passwordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
                        ),
                      ),
                      const SizedBox(height: 4),
                      Theme(
                        data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
                        child: CheckboxListTile(
                          onChanged: (value) => setState(() => visibility = value!),
                          value: visibility, 
                          contentPadding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text('Tampilkan Sandi', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 0)),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isValidated == true && loggingIn == false ? () {} : null,
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) return null;
                            return states.contains(MaterialState.pressed) ? 1 : 8;
                          }),
                          visualDensity: const VisualDensity(horizontal: 2, vertical: 2),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            return states.contains(MaterialState.disabled) ? null : Theme.of(context).colorScheme.primary;
                          }),
                          foregroundColor: MaterialStateProperty.resolveWith((states) {
                            return states.contains(MaterialState.disabled) ? null : Theme.of(context).colorScheme.surface;
                          }),
                          overlayColor: MaterialStateProperty.resolveWith((states) {
                            return states.contains(MaterialState.disabled) ? null : Theme.of(context).colorScheme.inversePrimary;
                          }),
                        ),
                        child: const Text('Masuk')
                      )
                    ],
                  );
                }
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(child: Divider(endIndent: 8)),
                Text('Lanjutkan dengan', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.w400)),
                const Expanded(child: Divider(indent: 8)),
              ]
            ),
            const SizedBox(height: 42),
            FutureBuilder(
              future: Authentication.initializeFirebase(context: context),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error initializing Firebase | Check your internet connectivity');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (FirebaseAuth.instance.currentUser == null) {
                    return GoogleSignInButton(
                      isLoading: loggingIn,
                      onPressed: () async {
                        hideSnackBar(context);
                        setState(() => loggingIn = true);
                        await Authentication.signInWithGoogle(context: context).then((value) {
                          if (value == null) setState(() => loggingIn = false);
                        });
                      }
                    );
                  } else {
                    CircularProgressIndicator(color: Theme.of(context).colorScheme.primary);
                  }
                }
                return CircularProgressIndicator(color: Theme.of(context).colorScheme.primary);
              },
            ),
          ],
        ),
      ),
    );
  }
}
