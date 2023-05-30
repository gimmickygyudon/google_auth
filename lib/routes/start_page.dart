import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../functions/google_signin.dart';
import '../widgets/button.dart';
import '../widgets/snackbar.dart';
import 'login_page.dart';

class StartPageRoute extends StatefulWidget {
  const StartPageRoute({super.key});

  @override
  State<StartPageRoute> createState() => _StartPageRouteState();
}

class _StartPageRouteState extends State<StartPageRoute> {
  late bool loggingIn, isValid;
  late TextEditingController _phonenumberController;

  @override
  void initState() {
    loggingIn = false;
    isValid = false;
    _phonenumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phonenumberController.dispose();
    super.dispose();
  }

  void pushLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginRoute()));
  }

  void validate() {
    if (_phonenumberController.text.trim().isEmpty) {
      setState(() => isValid = false);      
    } else {
      setState(() => isValid = true); 
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
            const Image(image: AssetImage('assets/Logo Indostar.png')),
            const SizedBox(height: 32),
            Column(
              children: [
                // Text('Hai, Customer', style: Theme.of(context).textTheme.headlineLarge),
                // const SizedBox(height: 12),
                Text('Mulailah mengelola bisnis anda dengan aman dan cepat.', 
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.secondary), textAlign: TextAlign.center
                ),
              ],
            ),
            const SizedBox(height: 100),
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
                      Text('Silakan masuk dengan menggunakkan nomor handphone Anda.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phonenumberController,
                        onChanged: (value) {
                          validate();
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Nomor HP',
                          enabledBorder: _phonenumberController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
                        )
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: isValid ? () => pushLogin() : null,
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
                      ),
                      const SizedBox(height: 16),
                      Text('Sudah mempunyai akun Customer Indostar?', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () {}, 
                        child: Text('Klik Disini', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary), textAlign: TextAlign.center)
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